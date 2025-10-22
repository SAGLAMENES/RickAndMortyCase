import SwiftUI
import RickAndMortyAPI

struct CharacterFilterView: View {
    @Binding var filter: CharacterFilter
    let onApply: () -> Void
    let onReset: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Spacing.xl) {
                    filterSection(
                        title: "Status",
                        items: Status.allCases,
                        selection: $filter.status,
                        displayName: { $0.displayName }
                    )
                    
                    filterSection(
                        title: "Gender",
                        items: Gender.allCases,
                        selection: $filter.gender,
                        displayName: { $0.displayName }
                    )
                }
                .padding(DS.Spacing.lg)
            }
            .background(RMColor.semantic.background)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") {
                        onReset()
                        dismiss()
                    }
                    .foregroundStyle(RMColor.semantic.textSecondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        onApply()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(RMColor.semantic.tint)
                }
            }
        }
    }
    
    private func filterSection<T: Equatable>(
        title: String,
        items: [T],
        selection: Binding<T?>,
        displayName: @escaping (T) -> String
    ) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text(title)
                .font(DS.Typography.subtitle)
                .foregroundStyle(RMColor.semantic.textPrimary)
            
            FlowLayout(spacing: DS.Spacing.sm) {
                ForEach(items.indices, id: \.self) { index in
                    FilterChip(
                        title: displayName(items[index]),
                        isSelected: selection.wrappedValue == items[index]
                    ) {
                        if selection.wrappedValue == items[index] {
                            selection.wrappedValue = nil
                        } else {
                            selection.wrappedValue = items[index]
                        }
                    }
                }
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = calculateLayout(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let layout = calculateLayout(proposal: proposal, subviews: subviews)
        for (index, frame) in layout.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: ProposedViewSize(frame.size))
        }
    }
    
    private func calculateLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let width = proposal.width ?? 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0
        var frames: [CGRect] = []
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if x + size.width > width && x > 0 {
                x = 0
                y += lineHeight + spacing
                lineHeight = 0
            }
            
            frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
            lineHeight = max(lineHeight, size.height)
            x += size.width + spacing
        }
        
        let totalHeight = y + lineHeight
        return (CGSize(width: width, height: totalHeight), frames)
    }
}

