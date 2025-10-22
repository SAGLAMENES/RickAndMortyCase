import SwiftUI
import RickAndMortyAPI
import RickAndMortyPersistence

struct CharactersView: View {
    @StateObject private var vm = CharacterListViewModel(api: RickAndMortyAPIClient())
    @State private var searchText = ""
    @State private var selectedCharacter: Character?
    @State private var showFilterSheet = false
    @State private var tempFilter = CharacterFilter()
    @State private var favorites: Set<Int> = []
    
    private let localStorage = DefaultCharacterLocalDataSource()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Rick & Morty Characters")
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $searchText, prompt: "Search characters")
                .onChange(of: searchText) { oldValue, newValue in
                    vm.searchCharacters(name: newValue)
                }
                .onSubmit(of: .search) {
                    vm.searchCharacters(name: searchText)
                }
                .navigationDestination(item: $selectedCharacter) { character in
                    CharacterDetailView(character: character)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { 
                            tempFilter = vm.filter
                            showFilterSheet = true 
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundStyle(vm.filter.isActive ? RMColor.semantic.tint : RMColor.semantic.textSecondary)
                        }
                    }
                }
                .sheet(isPresented: $showFilterSheet) {
                    CharacterFilterView(
                        filter: $tempFilter,
                        onApply: {
                            vm.updateFilter(tempFilter)
                        },
                        onReset: {
                            vm.resetFilters()
                        }
                    )
                }
        }
        .tint(RMColor.semantic.tint)
        .task {
            if case .idle = vm.state { vm.loadFirstPage() }
            loadFavorites()
        }
    }
    
    private func loadFavorites() {
        do {
            let allFavorites = try localStorage.fetchFavorites()
            favorites = Set(allFavorites.map { Int($0.id) })
        } catch {
            print("Error loading favorites: \(error)")
        }
    }
    
    private func toggleFavorite(for character: CharacterDTO) {
        let id = Int64(character.id)
        do {
            if try localStorage.isFavorite(id: id) {
                try localStorage.removeFavorite(id: id)
                favorites.remove(character.id)
            } else {
                try localStorage.addFavorite(character.toDomain().asLocal)
                favorites.insert(character.id)
            }
        } catch {
            print("Error toggling favorite: \(error)")
        }
    }

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle, .loading:
            ZStack {
                RMColor.semantic.background.ignoresSafeArea()
                ProgressView()
                    .tint(RMColor.semantic.accent)
                    .scaleEffect(1.2)
            }

        case .failed(let msg):
            ZStack {
                RMColor.semantic.background.ignoresSafeArea()
                VStack(spacing: DS.Spacing.lg) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(RMColor.semantic.accent)
                    
                    Text(msg)
                        .font(DS.Typography.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(RMColor.semantic.textPrimary)
                        .lineLimit(nil)
                    
                    Button("Tekrar Dene") {
                        vm.loadFirstPage()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(RMColor.semantic.tint)
                }
                .padding(DS.Spacing.xl)
            }

        case .loaded(let items):
            characterGrid(items)
        }
    }

    private func characterGrid(_ items: [CharacterDTO]) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if vm.filter.isActive {
                    activeFiltersBar
                }
                CharacterGrid(
                    items: items,
                    minItemWidth: 160,
                    spacing: DS.Spacing.lg,
                    maxColumns: 2
                ) { dto in
                    CharacterCardView(
                        model: dto.toUI(isFavorite: favorites.contains(dto.id)),
                        onTap: {
                            selectedCharacter = dto.toDomain()
                        },
                        onToggleFavorite: {
                            toggleFavorite(for: dto)
                        }
                    )
                    .onAppear {
                        if let index = items.firstIndex(where: { $0.id == dto.id }),
                           index >= items.count - 5 {
                            vm.loadNextPageIfAvailable()
                        }
                    }
                }
                .padding(DS.Spacing.lg)
            }
        }
        .background(RMColor.semantic.background.ignoresSafeArea())
    }
    
    private var activeFiltersBar: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("Active Filters")
                .font(DS.Typography.meta)
                .foregroundStyle(RMColor.semantic.textSecondary)
                .padding(.horizontal, DS.Spacing.lg)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Spacing.sm) {
                    if let status = vm.filter.status {
                        FilterTag(title: status.displayName, onRemove: {
                            var newFilter = vm.filter
                            newFilter.status = nil
                            vm.updateFilter(newFilter)
                        })
                    }
                    if let gender = vm.filter.gender {
                        FilterTag(title: gender.displayName, onRemove: {
                            var newFilter = vm.filter
                            newFilter.gender = nil
                            vm.updateFilter(newFilter)
                        })
                    }
                }
                .padding(.horizontal, DS.Spacing.lg)
            }
        }
        .padding(.vertical, DS.Spacing.md)
        .background(DS.Surface.card)
    }
}

private extension CharacterDTO {
    func toUI(isFavorite: Bool = false) -> CharacterUI {
        CharacterUI(
            id: id,
            name: name,
            imageURL: URL(string: image),
            statusLabel: status.label,
            statusIcon: status.icon,
            statusTint: status.tint,
            species: species,
            gender: gender.label,
            location: location.name,
            isFavorite: isFavorite
        )
    }
}

private extension Status {
    var label: String {
        switch self {
        case .alive: return "Alive"
        case .dead: return "Dead"
        case .unknown: return "Unknown"
        }
    }
    
    var icon: String {
        switch self {
        case .alive: return "heart.fill"
        case .dead: return "xmark.octagon.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }
    
    var tint: Color {
        switch self {
        case .alive: return .green
        case .dead: return .red
        case .unknown: return .gray
        }
    }
}

private extension Gender {
    var label: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        case .genderless: return "Genderless"
        case .unknown: return "Unknown"
        }
    }
}

#Preview {
    CharactersView()
        .preferredColorScheme(.dark)
}
