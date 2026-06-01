import SwiftUI

struct NovelMetadataPillRow: View {
    private enum Layout {
        static let rowHeight: CGFloat = 22
    }

    let texts: [String]
    var placeholder: String
    var maxCount: Int? = nil

    private var displayTexts: [String] {
        let normalized = texts
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let items = if let maxCount {
            Array(normalized.prefix(maxCount))
        } else {
            normalized
        }

        return items.isEmpty ? [placeholder] : items
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(Array(displayTexts.enumerated()), id: \.offset) { _, text in
                    NovelMetadataPill(text: text)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: Layout.rowHeight, maxHeight: Layout.rowHeight, alignment: .leading)
    }
}

private struct NovelMetadataPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2)
            .foregroundColor(.secondary)
            .lineLimit(1)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.secondary.opacity(0.1))
            .clipShape(Capsule())
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        NovelMetadataPillRow(
            texts: ["有系列的小说"],
            placeholder: "无系列",
            maxCount: 1
        )

        NovelMetadataPillRow(
            texts: ["原创", "长篇", "奇幻"],
            placeholder: "无标签",
            maxCount: 4
        )

        NovelMetadataPillRow(
            texts: [],
            placeholder: "无系列",
            maxCount: 1
        )
    }
    .padding()
}
