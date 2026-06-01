import SwiftUI

struct NovelInfoTableRow: View {
    private enum Layout {
        static let thumbnailSize: CGFloat = 80
        static let verticalSpacing: CGFloat = 4
        static let rowHeight: CGFloat = 17
    }

    let novel: Novel
    var titlePrefix: String?
    var showsBookmarkSummary = false
    var isBookmarked: Bool? = nil
    var bookmarkSummaryText: String? = nil

    private var resolvedIsBookmarked: Bool {
        isBookmarked ?? novel.isBookmarked
    }

    private var resolvedBookmarkSummaryText: String {
        bookmarkSummaryText ?? NumberFormatter.formatCount(novel.totalBookmarks)
    }

    private var titleText: String {
        if let titlePrefix, !titlePrefix.isEmpty {
            return "\(titlePrefix)\(novel.title)"
        }
        return novel.title
    }

    private var seriesText: String {
        let title = novel.series?.title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return title.isEmpty ? "无系列" : title
    }

    private var tagTexts: [String] {
        novel.tags.map(\.name)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            CachedAsyncImage(
                urlString: novel.imageUrls.medium,
                expiration: DefaultCacheExpiration.novel
            )
            .frame(width: Layout.thumbnailSize, height: Layout.thumbnailSize)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: Layout.verticalSpacing) {
                seriesColumn
                titleColumn
                authorColumn
                tagColumn
            }
            .frame(
                maxWidth: .infinity,
                minHeight: Layout.thumbnailSize,
                maxHeight: Layout.thumbnailSize,
                alignment: .topLeading
            )

            if showsBookmarkSummary {
                bookmarkColumn
                    .frame(width: 44)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }

    private var titleColumn: some View {
        Text(titleText)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.primary)
            .lineLimit(1, reservesSpace: true)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, minHeight: Layout.rowHeight, maxHeight: Layout.rowHeight, alignment: .leading)
    }

    private var seriesColumn: some View {
        NovelMetadataPillRow(
            texts: [seriesText],
            placeholder: "无系列",
            maxCount: 1,
            rowHeight: Layout.rowHeight
        )
    }

    private var authorColumn: some View {
        Text(novel.user.name)
            .font(.caption)
            .foregroundColor(.secondary)
            .lineLimit(1, reservesSpace: true)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, minHeight: Layout.rowHeight, maxHeight: Layout.rowHeight, alignment: .leading)
    }

    private var tagColumn: some View {
        NovelMetadataPillRow(
            texts: tagTexts,
            placeholder: "无标签",
            maxCount: 4,
            rowHeight: Layout.rowHeight
        )
    }

    private var bookmarkColumn: some View {
        VStack(spacing: 4) {
            Image(systemName: resolvedIsBookmarked ? "heart.fill" : "heart")
                .foregroundColor(resolvedIsBookmarked ? .red : .secondary)
                .font(.system(size: 18))

            Text(resolvedBookmarkSummaryText)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}
