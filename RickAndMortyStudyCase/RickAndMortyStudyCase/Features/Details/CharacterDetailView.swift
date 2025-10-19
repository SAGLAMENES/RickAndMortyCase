//
//  CharacterDetailView.swift
//  RickAndMortyStudyCase
//
//  Created by Enes on 13.10.2025.
//

import SwiftUI

struct CharacterDetailView: View {
    @StateObject private var vm: CharacterDetailViewModel

    init(character: Character) {
        _vm = StateObject(wrappedValue: CharacterDetailViewModel(character: character))
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                AsyncImage(url: vm.character.imageURL) { phase in
                    switch phase {
                    case .empty: ProgressView().frame(height: 260)
                    case .success(let img):
                        img.resizable()
                            .scaledToFit()
                            .frame(height: 260)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    case .failure:
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 260)
                    @unknown default:
                        Color.gray.opacity(0.1).frame(height: 260)
                    }
                }

                Text(vm.character.name)
                    .titleStyle()

                StatusRectangle(status: vm.character.status)

                VStack(spacing: 8) {
                    InfoRow(title: "Species", value: vm.character.species)
                    InfoRow(title: "Gender",  value: vm.character.gender.label)
                    InfoRow(title: "Location", value: vm.character.locationName)
                }
                .padding()
                .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
            .padding()
        }
        .navigationTitle(vm.character.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                vm.toggleFavorite()
            } label: {
                Image(systemName: vm.isFavorite ? "heart.fill" : "heart")
            }
        }
    }
}

private struct InfoRow: View {
    let title: String
    let value: String
    var body: some View {
        HStack {
            Text(title)
                .captionStyle()
            Spacer()
            Text(value)
                .captionStyle()

        }
    }
}

private struct StatusRectangle: View {
    let status: CharacterStatus
    
    var body: some View {
        Label {
            Text(status.label)
                .bodyStyle()
        } icon: {
            Image(systemName: status.symbolName)
                .imageScale(.small)
                .symbolRenderingMode(.monochrome) // istersen .palette
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(status.color.opacity(0.15), in: Capsule())
        .foregroundStyle(status.color)
        .accessibilityLabel(Text("\(status.label) status"))
    }
}


extension CharacterStatus {
    var label: String {
        switch self { case .alive: "Alive"; case .dead: "Dead"; case .unknown: "Unknown" }
    }
}

extension CharacterStatus {
    var color: Color {
        switch self { case .alive: .green; case .dead: .red; case .unknown: .gray }
    }
}

extension CharacterGender {
    var label: String {
        switch self { case .male: "Male"; case .female: "Female"; case .genderless: "Genderless"; case .unknown: "Unknown" }
    }
}

extension CharacterStatus {
    var symbolName: String {
        switch self {
        case .alive:   return "heart.fill"
        case .dead:    return "xmark.octagon.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }
}
