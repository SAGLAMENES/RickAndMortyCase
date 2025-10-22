//
//  CharacterListViewModel.swift
//  RickAndMortyStudyCase
//
//  Created by Enes on 13.10.2025.
//


import Foundation
import RickAndMortyAPI

protocol CharacterListViewModelProtocol {
    var state: CharacterListViewModel.State { get }
    var filter: CharacterFilter { get }
    
    func loadFirstPage()
    func loadNextPageIfAvailable()
    func extractNextPage(from info: Page<CharacterDTO>.Info?) -> Int?
    func searchCharacters(name: String?)
    func updateFilter(_ newFilter: CharacterFilter)
    func resetFilters()
}

@MainActor
final class CharacterListViewModel: ObservableObject, @preconcurrency CharacterListViewModelProtocol {
  
    
    enum State { case idle, loading, loaded([CharacterDTO]), failed(String) }

    @Published private(set) var state: State = .idle
    @Published var filter: CharacterFilter = CharacterFilter()

    private let api: RickAndMortyAPIProtocol
    private var lastInfo: Page<CharacterDTO>.Info?
    private var isLoading = false
    private var currentQueryName: String?
    private var searchTask: Task<Void, Never>?
    
    init(api: RickAndMortyAPIProtocol) {
        self.api = api
    }

    func loadFirstPage() {
        guard !isLoading else { return }
        isLoading = true
        state = .loading
        currentQueryName = nil
        Task {
            defer { isLoading = false }
            do {
                let page1 = try await api.listCharacters(
                    page: 1,
                    name: nil,
                    status: filter.status,
                    gender: filter.gender
                )
                lastInfo = page1.info
                state = .loaded(page1.results)
            } catch {
                state = .failed(error.localizedDescription)
            }
        }
    }

    func loadNextPageIfAvailable() {
        guard !isLoading, let nextPage = extractNextPage(from: lastInfo) else { return }
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                let next = try await api.listCharacters(
                    page: nextPage,
                    name: currentQueryName,
                    status: filter.status,
                    gender: filter.gender
                )
                lastInfo = next.info
                if case .loaded(let old) = state {
                    state = .loaded(old + next.results)
                } else {
                    state = .loaded(next.results)
                }
            } catch {
                state = .failed(error.localizedDescription)
            }
        }
    }

    func extractNextPage(from info: Page<CharacterDTO>.Info?) -> Int? {
        guard let next = info?.next,
              let comps = URLComponents(string: next),
              let val = comps.queryItems?.first(where: { $0.name == "page" })?.value,
              let page = Int(val) else { return nil }
        return page
    }
    
    func searchCharacters(name: String?) {
        searchTask?.cancel()

        let query = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalized: String? = (query?.isEmpty == false) ? query : nil
        currentQueryName = normalized

        isLoading = true
        state = .loading

        searchTask = Task { [weak self] in
            guard let self else { return }
            defer { self.isLoading = false }
            do {
                try await Task.sleep(nanoseconds: 150_000_000)
                let page1 = try await self.api.listCharacters(
                    page: 1,
                    name: self.currentQueryName,
                    status: self.filter.status,
                    gender: self.filter.gender
                )
                self.lastInfo = page1.info
                self.state = .loaded(page1.results)
            } catch is CancellationError {
            } catch {
                self.state = .failed(error.localizedDescription)
            }
        }
    }
    
    func updateFilter(_ newFilter: CharacterFilter) {
        filter = newFilter
        loadFirstPage()
    }
    
    func resetFilters() {
        filter.reset()
        loadFirstPage()
    }
}


extension CharacterDTO {
    func toDomain() -> Character {
        Character(
            id: id,
            name: name,
            status: .init(dto: status),
            gender: .init(dto: gender),
            species: species,
            imageURL: URL(string: image),
            locationName: location.name,
            originName: origin.name,
            episodeCount: episode.count
        )
    }
}


private extension CharacterStatus {
    init(dto: Status) {
        switch dto {
        case .alive: self = .alive
        case .dead: self = .dead
        case .unknown: self = .unknown
        @unknown default:
            fatalError()
        }
    }
}
private extension CharacterGender {
    init(dto: Gender) {
        switch dto {
        case .male: self = .male
        case .female: self = .female
        case .genderless: self = .genderless
        case .unknown: self = .unknown
        @unknown default:
            fatalError()
        }
    }
}

