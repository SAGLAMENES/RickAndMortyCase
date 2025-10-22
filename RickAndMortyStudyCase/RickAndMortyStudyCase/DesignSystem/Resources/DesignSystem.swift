//
//  DesignSystem.swift
//  RickAndMortyStudyCase
//
//  Created by Enes on 17.10.2025.
//

import Foundation
import SwiftUI


public enum DS {
    public enum Spacing {
        public static let xs: CGFloat = 6
        public static let sm: CGFloat = 10
        public static let md: CGFloat = 14
        public static let lg: CGFloat = 18
        public static let xl: CGFloat = 24
    }
    public enum Radius {
        public static let sm: CGFloat = 10
        public static let md: CGFloat = 14
        public static let lg: CGFloat = 20
        public static let xl: CGFloat = 28
    }
    public enum Elevation {
        // Very soft, card-like
        public static let card = Shadow(radius: 12, y: 6, opacity: 0.15)
        public struct Shadow { let radius: CGFloat; let y: CGFloat; let opacity: CGFloat }
    }
    public enum Surface {
        public static var card: Color { Color(.secondarySystemBackground) }
        public static var chip: Color { Color(.tertiarySystemBackground) }
    }
    public enum Typography {
        public static var title: Font { .title3.weight(.semibold) }
        public static var subtitle: Font { .subheadline.weight(.semibold) }
        public static var body: Font { .callout }
        public static var meta: Font { .footnote }
    }
}

public struct CardShadow: ViewModifier {
    let e = DS.Elevation.card
    public func body(content: Content) -> some View {
        content.shadow(color: .black.opacity(e.opacity), radius: e.radius, x: 0, y: e.y)
    }
}
extension View { public func cardShadow() -> some View { modifier(CardShadow()) } }



public struct XGrid: Layout {
    public var minItemWidth: CGFloat
    public var spacing: CGFloat
    public var maxColumns: Int?

    public init(minItemWidth: CGFloat = 160, spacing: CGFloat = DS.Spacing.md, maxColumns: Int? = nil) {
        self.minItemWidth = minItemWidth
        self.spacing = spacing
        self.maxColumns = maxColumns
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let width = proposal.width ?? 0
        let cols = columns(for: width)
        guard cols > 0 else { return .zero }
        let columnWidth = (width - CGFloat(cols - 1) * spacing) / CGFloat(cols)
        var heights = Array(repeating: CGFloat(0), count: cols)
        var maxY: CGFloat = 0

        for index in subviews.indices {
            let col = heights.enumerated().min(by: { $0.element < $1.element })!.offset
            let fitted = subviews[index].sizeThatFits(.init(width: columnWidth, height: nil))
            heights[col] += fitted.height + spacing
            maxY = max(maxY, heights[col])
        }
        if !subviews.isEmpty { maxY -= spacing }
        return CGSize(width: width, height: maxY)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let width = bounds.width
        let cols = columns(for: width)
        guard cols > 0 else { return }
        let columnWidth = (width - CGFloat(cols - 1) * spacing) / CGFloat(cols)
        var heights = Array(repeating: CGFloat(0), count: cols)

        for index in subviews.indices {
            let col = heights.enumerated().min(by: { $0.element < $1.element })!.offset
            let x = bounds.minX + CGFloat(col) * (columnWidth + spacing)
            let y = bounds.minY + heights[col]
            let fitted = subviews[index].sizeThatFits(.init(width: columnWidth, height: nil))
            subviews[index].place(at: CGPoint(x: x, y: y), proposal: .init(width: columnWidth, height: fitted.height))
            heights[col] += fitted.height + spacing
        }
    }

    private func columns(for containerWidth: CGFloat) -> Int {
        guard containerWidth > 0 else { return 1 }
        let natural = max(1, Int((containerWidth + spacing) / (minItemWidth + spacing)))
        if let maxColumns { return min(natural, maxColumns) }
        return natural
    }
}


public struct StatusChip: View {
    public let title: String
    public let icon: String
    public let tint: Color

    public init(title: String, icon: String, tint: Color) {
        self.title = title; self.icon = icon; self.tint = tint
    }

    public var body: some View {
        Label {
            Text(title).font(DS.Typography.meta)
                .fontWeight(.semibold)
        } icon: {
            Image(systemName: icon).imageScale(.small)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tint.opacity(0.14), in: Capsule())
        .foregroundStyle(tint)
        .accessibilityLabel(Text("Status: \(title)"))
    }
}

public struct FilterChip: View {
    public let title: String
    public let isSelected: Bool
    public let action: () -> Void
    
    public init(title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(DS.Typography.meta)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected ? RMColor.semantic.tint : DS.Surface.chip,
                    in: Capsule()
                )
                .foregroundStyle(isSelected ? .black : RMColor.semantic.textPrimary)
        }
        .buttonStyle(.plain)
    }
}

public struct FilterTag: View {
    public let title: String
    public let onRemove: () -> Void
    
    public init(title: String, onRemove: @escaping () -> Void) {
        self.title = title
        self.onRemove = onRemove
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(DS.Typography.meta)
                .fontWeight(.medium)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .imageScale(.small)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(RMColor.semantic.tint.opacity(0.2), in: Capsule())
        .foregroundStyle(RMColor.semantic.tint)
    }
}



public struct AsyncRemoteImage: View {
    public let url: URL?
    public let height: CGFloat
    public init(url: URL?, height: CGFloat) { self.url = url; self.height = height }

    public var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ZStack { ProgressView() }
                    .frame(height: height)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            case .success(let img):
                img.resizable().scaledToFill()
                    .frame(height: height)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            case .failure:
                RoundedRectangle(cornerRadius: DS.Radius.lg)
                    .fill(Color.gray.opacity(0.12))
                    .frame(height: height)
                    .overlay(Image(systemName: "photo").imageScale(.large).foregroundStyle(.secondary))
            @unknown default:
                Color.gray.opacity(0.1)
                    .frame(height: height)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg))
            }
        }
    }
}


public struct FavoriteButton: View {
    public let isOn: Bool
    public let action: () -> Void
    public init(isOn: Bool, action: @escaping () -> Void) { self.isOn = isOn; self.action = action }
    public var body: some View {
        Button(action: action) {
            Image(systemName: isOn ? "heart.fill" : "heart")
                .imageScale(.medium)
                .padding(6)
                .background(.ultraThinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(isOn ? .red : .primary)
        .accessibilityLabel(Text(isOn ? "Remove from favorites" : "Add to favorites"))
    }
}



public struct CharacterUI: Identifiable, Hashable {
    public let id: Int
    public let name: String
    public let imageURL: URL?
    public let statusLabel: String
    public let statusIcon: String
    public let statusTint: Color
    public let species: String
    public let gender: String
    public let location: String
    public var isFavorite: Bool

    public init(id: Int, name: String, imageURL: URL?, statusLabel: String, statusIcon: String, statusTint: Color, species: String, gender: String, location: String, isFavorite: Bool) {
        self.id = id; self.name = name; self.imageURL = imageURL
        self.statusLabel = statusLabel; self.statusIcon = statusIcon; self.statusTint = statusTint
        self.species = species; self.gender = gender; self.location = location
        self.isFavorite = isFavorite
    }
}

public struct CharacterCardView: View {
    public let model: CharacterUI
    public let onTap: () -> Void
    public let onToggleFavorite: () -> Void
    public init(model: CharacterUI, onTap: @escaping () -> Void, onToggleFavorite: @escaping () -> Void) {
        self.model = model; self.onTap = onTap; self.onToggleFavorite = onToggleFavorite
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            ZStack(alignment: .topTrailing) {
                AsyncRemoteImage(url: model.imageURL, height: 180)
                HStack {
                    StatusChip(title: model.statusLabel, icon: model.statusIcon, tint: model.statusTint)
                        .padding(6)
                    Spacer(minLength: 0)
                    FavoriteButton(isOn: model.isFavorite, action: onToggleFavorite)
                        .padding(6)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(model.name)
                    .font(DS.Typography.title)
                    .lineLimit(1)
                Text(model.species)
                    .font(DS.Typography.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse").imageScale(.small)
                    Text(model.location).font(DS.Typography.meta).foregroundStyle(.secondary)
                }.lineLimit(1)
            }
            .padding(.horizontal, DS.Spacing.sm)
            .padding(.bottom, DS.Spacing.sm)
        }
        .background(DS.Surface.card, in: RoundedRectangle(cornerRadius: DS.Radius.md))
        .contentShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .cardShadow()
        .onTapGesture(perform: onTap)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(model.name), \(model.statusLabel)"))
    }
}


public struct CharacterGrid<Item: Identifiable, Cell: View>: View {
    public let items: [Item]
    public var minItemWidth: CGFloat
    public var spacing: CGFloat
    public var maxColumns: Int?
    public let cell: (Item) -> Cell

    public init(items: [Item], minItemWidth: CGFloat = 170, spacing: CGFloat = DS.Spacing.md, maxColumns: Int? = nil, @ViewBuilder cell: @escaping (Item) -> Cell) {
        self.items = items; self.minItemWidth = minItemWidth; self.spacing = spacing; self.maxColumns = maxColumns; self.cell = cell
    }

    public var body: some View {
        XGrid(minItemWidth: minItemWidth, spacing: spacing, maxColumns: maxColumns) {
            ForEach(items) { item in
                cell(item)
            }
        }
    }
}



public extension CharacterUI {
    init(character: Character, isFavorite: Bool) {
        self.init(
            id: character.id,
            name: character.name,
            imageURL: character.imageURL,
            statusLabel: character.status.label,
            statusIcon: character.status.symbolName,
            statusTint: character.status.color,
            species: character.species,
            gender: character.gender.label,
            location: character.locationName,
            isFavorite: isFavorite
        )
    }
}



struct CharactersGridPage: View {
    let models: [CharacterUI]
    let onTap: (CharacterUI) -> Void
    let toggleFavorite: (CharacterUI) -> Void

    var body: some View {
        ScrollView {
            CharacterGrid(items: models, minItemWidth: 168, maxColumns: nil) { model in
                CharacterCardView(model: model, onTap: { onTap(model) }, onToggleFavorite: { toggleFavorite(model) })
            }
            .padding(DS.Spacing.lg)
        }
        .navigationTitle("Characters")
    }
}

struct CharactersEmbeddedSection: View {
    let models: [CharacterUI]
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Related Characters").font(DS.Typography.subtitle)
            CharacterGrid(items: models, minItemWidth: 150, maxColumns: 3) { model in
                CharacterCardView(model: model, onTap: {}, onToggleFavorite: {})
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
    }
}


