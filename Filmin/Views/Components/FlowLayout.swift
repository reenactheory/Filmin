import SwiftUI

/// A wrap / flow layout: lays subviews left-to-right, breaking
/// to a new line when the next subview would overflow the available
/// width. Each row can be individually horizontally aligned.
struct FlowLayout: Layout {
    var horizontalSpacing: CGFloat = 8
    var verticalSpacing: CGFloat = 8
    var alignment: HorizontalAlignment = .leading

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        let rows = computeRows(in: width, subviews: subviews)
        let totalHeight = rows.last.map { $0.y + $0.height } ?? 0
        let maxRowWidth = rows.map(\.width).max() ?? 0
        return CGSize(width: maxRowWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(in: bounds.width, subviews: subviews)

        for row in rows {
            var x: CGFloat
            switch alignment {
            case .center:
                x = bounds.minX + (bounds.width - row.width) / 2
            case .trailing:
                x = bounds.minX + bounds.width - row.width
            default:
                x = bounds.minX
            }

            for itemIndex in row.items {
                let size = subviews[itemIndex].sizeThatFits(.unspecified)
                subviews[itemIndex].place(
                    at: CGPoint(x: x, y: bounds.minY + row.y),
                    proposal: .unspecified
                )
                x += size.width + horizontalSpacing
            }
        }
    }

    private struct Row {
        var items: [Int] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
        var y: CGFloat = 0
    }

    private func computeRows(in width: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var current = Row()

        for (idx, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            let proposedWidth = current.items.isEmpty
                ? size.width
                : current.width + horizontalSpacing + size.width

            if proposedWidth > width, !current.items.isEmpty {
                rows.append(current)
                current = Row(
                    items: [idx],
                    width: size.width,
                    height: size.height,
                    y: current.y + current.height + verticalSpacing
                )
            } else {
                current.items.append(idx)
                current.width = proposedWidth
                current.height = max(current.height, size.height)
            }
        }

        if !current.items.isEmpty {
            rows.append(current)
        }
        return rows
    }
}
