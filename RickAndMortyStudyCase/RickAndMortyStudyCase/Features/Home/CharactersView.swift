//
//  ContentView.swift
//  RickAndMortyStudyCase
//
//  Created by Enes on 13.10.2025.
//

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
                .onChange(of: searchText) { oldVal, newValue in
                    vm.searchCharacters(name: newValue)
                }
                .onSubmit(of: .search) {
                    vm.searchCharacters(name: searchText)
                }
                .task {
                    if case .idle = vm.state { vm.loadFirstPage() }
                }
        }
        .task {
            vm.loadFirstPage()
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle, .loading:
            ProgressView("Yükleniyor..")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let msg):
            VStack(spacing: 12) {
                Text("Hata: \(msg)")
                    .multilineTextAlignment(.center)
                Button("Tekrar Dene") {
                    vm.loadFirstPage()
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let items):
            List(Array(items.enumerated()), id: \.element.id) { index, ch in
                HStack(spacing: 12) {
                    NavigationLink(destination: CharacterDetailView(character: ch.toDomain())) {
                        if let url = URL(string: ch.image) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty: ProgressView()
                                case .success(let img): img.resizable().scaledToFit()
                                case .failure: Color.gray.opacity(0.2)
                                @unknown default: Color.gray.opacity(0.2)
                                }
                            }
                            .frame(width: 44, height: 44)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        VStack(alignment: .leading) {
                            Text(ch.name)
                                .font(.headline)
                            
                            Text("\(ch.status.rawValue) • \(ch.gender.rawValue)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    
                }
                .onAppear {
                    if  index >= items.count - 5 {
                        vm.loadNextPageIfAvailable()
                    }
                }
            }
        }
    }
}

#Preview {
    CharactersView()
}

