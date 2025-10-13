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
    enum State {
        case idle, loading
        case loaded([CharacterDTO])
        case failed(String)
    }

    @Published var state: State = .idle
    private let api = RickAndMortyAPIClient()

    func loadFirstPage() {
        state = .loading
        Task {
            do {
                let page1 = try await api.listCharacters(page: 1)
                // Konsola da basalım (debug için):
                print("✅ API OK, count:", page1.results.count,
                      "first:", page1.results.first?.name ?? "-")
                state = .loaded(page1.results)
            } catch {
                print("❌ API ERROR:", error)
                if let ae = error as? APIError { state = .failed(ae.localizedDescription) }
                else { state = .failed(error.localizedDescription) }
            }
        }
    }
}
