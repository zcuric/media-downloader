import SwiftUI

struct HistoryListView: View {
    let items: [DownloadItem]
    let onCopy: (DownloadItem) -> Void
    let onReveal: (DownloadItem) -> Void
    let onOpenSource: (DownloadItem) -> Void
    let onEdit: (DownloadItem) -> Void
    private let rowHeight: CGFloat = 74
    private let verticalPadding: CGFloat = 20

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(items) { item in
                    HistoryRowView(
                        item: item,
                        onCopy: { onCopy(item) },
                        onReveal: { onReveal(item) },
                        onOpenSource: { onOpenSource(item) },
                        onEdit: { onEdit(item) }
                    )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .scrollIndicators(.hidden)
        .frame(width: 680)
        .frame(height: panelHeight)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.16), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.16), radius: 24, x: 0, y: 14)
    }

    private var panelHeight: CGFloat {
        let visibleCount = min(max(items.count, 1), 4)
        let cappedListAdjustment: CGFloat = items.count > 4 ? 4 : 0
        return CGFloat(visibleCount) * rowHeight + verticalPadding - cappedListAdjustment
    }
}
