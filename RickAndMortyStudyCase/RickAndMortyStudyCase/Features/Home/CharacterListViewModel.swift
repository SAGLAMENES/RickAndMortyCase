//
//  CharacterListViewModel.swift
//  RickAndMortyStudyCase
//
//  Created by Enes on 13.10.2025.
//


import Foundation
import RickAndMortyAPI

@MainActor
final class CharacterListViewModel: ObservableObject {
    enum State { case idle, loading, loaded([CharacterDTO]), failed(String) }

    @Published private(set) var state: State = .idle

    private let api: RickAndMortyAPIProtocol
    private var lastInfo: CharactersPage.Info?
    private var isLoading = false

    init(api: RickAndMortyAPIProtocol) {
        self.api = api
    }

    func loadFirstPage() {
        guard !isLoading else { return }
        isLoading = true
        state = .loading
        Task {
            defer { isLoading = false }
            do {
                let page1 = try await api.listCharacters(page: 1, name: nil, status: nil, gender: nil)
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
                let next = try await api.listCharacters(page: nextPage, name: nil, status: nil, gender: nil)
                lastInfo = next.info
                switch state {
                case .loaded(let old):
                    state = .loaded(old + next.results)
                case .idle, .loading:
                    state = .loaded(next.results)
                case .failed:
                    break
                }
            } catch {
                state = .failed(error.localizedDescription)
            }
        }
    }

    private func extractNextPage(from info: CharactersPage.Info?) -> Int? {
        guard let next = info?.next,
              let comps = URLComponents(string: next),
              let val = comps.queryItems?.first(where: { $0.name == "page" })?.value,
              let page = Int(val)
        else { return nil }
        return page
    }
}
import RickAndMortyAPI

extension CharacterDTO {
    func toDomain() -> Character {
        Character(
            id: id,
            name: name,
            status: .init(dto: status),
            gender: .init(dto: gender),
            species: species,
            imageURL: URL(string: image),
            locationName: location.name
        )
    }
}

private extension CharacterStatus {
    init(dto: Status) {
        switch dto {
        case .alive: self = .alive
        case .dead: self = .dead
        case .unknown: self = .unknown
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
        }
    }
}
