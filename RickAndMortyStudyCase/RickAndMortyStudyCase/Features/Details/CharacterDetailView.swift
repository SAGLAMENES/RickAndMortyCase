//
//  CharacterDetailView.swift
//  RickAndMortyStudyCase
//
//  Created by Enes on 13.10.2025.
//

import SwiftUI
import RickAndMortyAPI

struct CharacterDetailView: View {
    @StateObject private var vm: CharacterDetailViewModel
    @State private var selectedCharacter: Character?

    init(character: Character) {
        _vm = StateObject(wrappedValue: CharacterDetailViewModel(character: character))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Spacing.lg) {
                    headerSection
                    infoSection
                    
                    if !vm.relatedByLocation.isEmpty {
                        relatedSection(
                            title: "Same Location",
                            characters: vm.relatedByLocation
                        )
                    }
                    
                    if !vm.relatedByEpisode.isEmpty {
                        relatedSection(
                            title: "Related Characters",
                            characters: vm.relatedByEpisode
                        )
                    }
                }
                .padding(DS.Spacing.lg)
            }
            .background(RMColor.semantic.background)
            .navigationTitle(vm.character.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.toggleFavorite()
                    } label: {
                        Image(systemName: vm.isFavorite ? "heart.fill" : "heart")
                    }
                    .foregroundStyle(vm.isFavorite ? .red : .primary)
                }
            }
            .task {
                vm.loadRelatedCharacters()
            }
            .navigationDestination(item: $selectedCharacter) { character in
                CharacterDetailView(character: character)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: DS.Spacing.md) {
            AsyncRemoteImage(url: vm.character.imageURL, height: 280)
                .frame(maxWidth: .infinity)
            
            Text(vm.character.name)
                .font(DS.Typography.title)
                .foregroundStyle(RMColor.semantic.textPrimary)
        }
    }
    
    private var infoSection: some View {
        VStack(spacing: DS.Spacing.md) {
            HStack(spacing: DS.Spacing.md) {
                StatusIndicator(status: vm.character.status)
                Spacer()
                InfoBadge(label: vm.character.gender.label, icon: "person.fill")
                InfoBadge(label: vm.character.species, icon: "waveform.circle.fill")
            }
            
            Divider()
                .overlay(RMColor.semantic.tint.opacity(0.3))
            
            VStack(spacing: DS.Spacing.sm) {
                LocationRow(
                    icon: "mappin.and.ellipse",
                    label: "Last Known Location",
                    value: vm.character.locationName
                )
                
                LocationRow(
                    icon: "globe",
                    label: "Origin",
                    value: vm.character.originName
                )
                
                LocationRow(
                    icon: "film",
                    label: "Episodes",
                    value: "\(vm.character.episodeCount) episodes"
                )
            }
        }
        .padding(DS.Spacing.md)
        .background(DS.Surface.card, in: RoundedRectangle(cornerRadius: DS.Radius.md))
    }
    
    @ViewBuilder
    private func relatedSection(title: String, characters: [CharacterDTO]) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text(title)
                .font(DS.Typography.subtitle)
                .foregroundStyle(RMColor.semantic.textPrimary)
                .padding(.horizontal, DS.Spacing.sm)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Spacing.md) {
                    ForEach(characters.prefix(6)) { character in
                        relatedCharacterCard(character)
                    }
                }
                .padding(.horizontal, DS.Spacing.sm)
            }
        }
    }
    
    private func relatedCharacterCard(_ dto: CharacterDTO) -> some View {
        Button(action: { selectedCharacter = dto.toDomain() }) {
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                AsyncRemoteImage(url: URL(string: dto.image), height: 140)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(dto.name)
                        .font(DS.Typography.body)
                        .lineLimit(1)
                        .foregroundStyle(RMColor.semantic.textPrimary)
                    
                    Text(dto.species)
                        .font(DS.Typography.meta)
                        .lineLimit(1)
                        .foregroundStyle(RMColor.semantic.textSecondary)
                }
                .padding(.horizontal, DS.Spacing.sm)
                .padding(.bottom, DS.Spacing.sm)
            }
            .frame(width: 160)
            .background(DS.Surface.card, in: RoundedRectangle(cornerRadius: DS.Radius.md))
        }
    }
}

private struct StatusIndicator: View {
    let status: CharacterStatus
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(statusLabel)
                .font(DS.Typography.meta)
                .fontWeight(.semibold)
                .foregroundStyle(RMColor.semantic.textPrimary)
        }
        .padding(.horizontal, DS.Spacing.sm)
        .padding(.vertical, 6)
        .background(statusColor.opacity(0.15), in: Capsule())
        .foregroundStyle(statusColor)
    }
    
    private var statusLabel: String {
        switch status {
        case .alive: return "Alive"
        case .dead: return "Dead"
        case .unknown: return "Unknown"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .alive: return .green
        case .dead: return .red
        case .unknown: return .gray
        }
    }
}

private struct InfoBadge: View {
    let label: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .imageScale(.small)
            Text(label)
                .font(DS.Typography.meta)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(DS.Surface.chip, in: Capsule())
        .foregroundStyle(RMColor.semantic.textSecondary)
    }
}

private struct LocationRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .imageScale(.small)
                    .foregroundStyle(RMColor.semantic.tint)
                
                Text(label)
                    .font(DS.Typography.meta)
                    .foregroundStyle(RMColor.semantic.textSecondary)
            }
            
            Text(value)
                .font(DS.Typography.body)
                .foregroundStyle(RMColor.semantic.textPrimary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
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
