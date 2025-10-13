//
//  CharacterDetailView.swift
//  RickAndMortyStudyCase
//
//  Created by Enes on 13.10.2025.
//

import SwiftUI

struct CharacterDetailView: View {
    let character: Character
    @State private var isFavorite: Bool

    init(character: Character) {
        self.character = character
        _isFavorite = State(initialValue: character.isFavorite)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                AsyncImage(url: character.imageURL) { phase in
                    switch phase {
                    case .empty: ProgressView().frame(height: 260)
                    case .success(let img):
                        img.resizable().scaledToFit()
                            .frame(height: 260).clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    case .failure:
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.15))
                            Image(systemName: "person.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(.secondary)
                        }
                        .frame(height: 260)
                    @unknown default:
                        Color.gray.opacity(0.1).frame(height: 260)
                    }
                }

                VStack(spacing: 8) {
                    Text(character.name)
                        .font(.title).fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    StatusRectangle(status: character.status)
                }

                VStack(spacing: 12) {
                    InfoRow(title: "Species", value: character.species)
                    InfoRow(title: "Gender",  value: character.gender.label)
                    InfoRow(title: "Location", value: character.locationName)
                }
                .padding()
                .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
            .padding()
        }
        .navigationTitle(character.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                isFavorite.toggle()
                // TODO: CoreDAta geleck
            } label: {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
            }
        }
    }
}

private struct InfoRow: View {
    let title: String
    let value: String
    var body: some View {
        HStack {
            Text(title).fontWeight(.semibold)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
    }
}

private struct StatusRectangle: View {
    let status: CharacterStatus

    var body: some View {
        Label {
            Text(status.label)
                .font(.subheadline).fontWeight(.semibold)
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
