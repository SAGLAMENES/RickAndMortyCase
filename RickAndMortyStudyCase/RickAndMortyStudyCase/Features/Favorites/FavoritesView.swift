//
//  FavoritesView.swift
//  RickAndMortyStudyCase
//
//  Created by Enes on 13.10.2025.
//

import SwiftUI

struct FavoritesView: View {
    @StateObject var vm: FavoritesViewModel = FavoritesViewModel()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Favorites")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            vm.load()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .help("Refresh")
                    }
                }
        }
        .task { vm.load() }
        .onAppear { vm.load() }
    }

    @ViewBuilder
    private var content: some View {
        if vm.isLoading {
            ProgressView("Yükleniyor").frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let msg = vm.errorMessage {
            VStack(spacing: 12) {
                Text("Hata").font(.headline)
                Text(msg).multilineTextAlignment(.center)
                Button("Tekrar Dene") {
                    vm.load()
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if vm.items.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "heart")
                    .font(.system(size: 44))
                Text("Henüz favori yok")
                    .foregroundStyle(.secondary)
                Text("Karakter detayından kalbe dokunarak favorilere ekle.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                ForEach(vm.items, id: \.id) { ch in
                    NavigationLink(value: ch) {
                        FavoriteRow(character: ch) {
                            vm.remove(ch)
                        }
                    }
                }
                .onDelete(perform: onDelete)
            }
            .navigationDestination(for: Character.self) { ch in
                CharacterDetailView(character: ch)
            }
        }
    }

    private func onDelete(_ offsets: IndexSet) {
        for idx in offsets {
            let ch = vm.items[idx]
            vm.remove(ch)
        }
    }
}

private struct FavoriteRow: View {
    let character: Character
    var onUnfavorite: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            if let url = character.imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty: ProgressView()
                    case .success(let img): img.resizable().scaledToFill()
                    case .failure: Color.gray.opacity(0.2)
                    @unknown default: Color.gray.opacity(0.2)
                    }
                }
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(character.name).font(.headline)
                HStack(spacing: 8) {
                    StatusBadge(status: character.status)
                    Text(character.gender.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button(action: onUnfavorite) {
                Image(systemName: "heart.fill")
            }
            .buttonStyle(.borderless) // List seçimleriyle çakışmasın
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Küçük rozet

private struct StatusBadge: View {
    let status: CharacterStatus
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status == .alive ? "heart.text.square" :
                              status == .dead  ? "xmark.circle" :
                                                 "questionmark.circle")
                .font(.caption)
            Text(status.label)
                .font(.caption).fontWeight(.semibold)
        }
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(status.color.opacity(0.15))
        .foregroundStyle(status.color)
        .clipShape(Capsule())
    }
}


#Preview {
    FavoritesView()
}
