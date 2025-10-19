import SwiftUI
import RickAndMortyAPI

struct CharactersView: View {
    @StateObject private var vm = CharacterListViewModel(api: RickAndMortyAPIClient())
    @State private var searchText = ""

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
        }
        .tint(RMColor.semantic.tint)
        .toolbarBackground(RMColor.semantic.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            if case .idle = vm.state { vm.loadFirstPage() }
        }
        .background(RMColor.semantic.background)
    }

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle, .loading:
            ProgressView("Yükleniyor…")
                .progressViewStyle(.circular)
                .tint(RMColor.semantic.accent)
                .foregroundStyle(RMColor.semantic.textSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(RMColor.semantic.background)

        case .failed(let msg):
            VStack(spacing: 12) {
                Text("Hata: \(msg)")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(RMColor.semantic.textPrimary)

                Button("Tekrar Dene") { vm.loadFirstPage() }
                    .buttonStyle(.borderedProminent)
                    .tint(RMColor.semantic.tint)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(RMColor.semantic.background)

        case .loaded(let items):
            characterList(items)
        }
    }

    private func characterList(_ items: [CharacterDTO]) -> some View {
        List {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, ch in
                NavigationLink {
                    CharacterDetailView(character: ch.toDomain())
                } label: {
                    CharacterRowCard(ch: ch)
                }
                .listRowBackground(RMColor.semantic.surface)
                .onAppear {
                    if index >= items.count - 5 {
                        vm.loadNextPageIfAvailable()
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(RMColor.semantic.background)
    }
}

private struct CharacterRowCard: View {
    let ch: CharacterDTO

    var body: some View {
        HStack(spacing: 12) {
            avatar
            VStack(alignment: .leading, spacing: 2) {
                Text(ch.name)
                    .bodyStyle()
                    .foregroundStyle(RMColor.semantic.textPrimary)
                Text("\(ch.status.rawValue) • \(ch.gender.rawValue)")
                    .captionStyle()
                    .foregroundStyle(RMColor.semantic.textSecondary)
            }
            Spacer()
        }
        .padding(10)
        .background(RMColor.semantic.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var avatar: some View {
        if let url = URL(string: ch.image) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        RMColor.semantic.surface
                        ProgressView().tint(RMColor.semantic.accent)
                    }
                case .success(let img):
                    img.resizable().scaledToFit()
                        .frame(width: 75,height: 125)
                    
                case .failure:
                    Image(systemName: "photo")
                        .imageScale(.large)
                        .foregroundStyle(RMColor.semantic.textSecondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                @unknown default:
                    Color.gray.opacity(0.2)
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
    }
}

#Preview {
    CharactersView()
        .preferredColorScheme(.dark)
}
