import SwiftUI

@MainActor
enum ResponsiveGrid {
    static func columnCount(
        for containerWidth: CGFloat,
        userSetting: UserSetting? = nil
    ) -> Int {
        if let setting = userSetting {
            if !setting.crossAdapt {
                return setting.crossCount
            }
        }

        return containerWidth >= 414 ? 3 : 2
    }

    static func initialColumnCount(userSetting: UserSetting) -> Int {
        if !userSetting.crossAdapt {
            return userSetting.crossCount
        }
        return 2
    }

    static func userColumnCount(for containerWidth: CGFloat) -> Int {
        containerWidth >= 600 ? 2 : 1
    }
}

@MainActor
struct ResponsiveGridModifier: ViewModifier {
    let userSetting: UserSetting?
    @Binding var columnCount: Int
    var measuredWidth: Binding<CGFloat>?
    @State private var lastWidth: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            updateColumnCount(for: proxy.size.width)
                        }
                        .onChange(of: proxy.size.width) { _, newWidth in
                            updateColumnCount(for: newWidth)
                        }
                        .onChange(of: userSetting) { _, _ in
                            updateColumnCount(for: lastWidth)
                        }
                        .onChange(of: userSetting?.crossCount) { _, _ in updateColumnCount(for: lastWidth) }
                        .onChange(of: userSetting?.hCrossCount) { _, _ in updateColumnCount(for: lastWidth) }
                        .onChange(of: userSetting?.crossAdapt) { _, _ in updateColumnCount(for: lastWidth) }
                        .onChange(of: userSetting?.hCrossAdapt) { _, _ in updateColumnCount(for: lastWidth) }
                }
            )
    }

    private func updateColumnCount(for width: CGFloat) {
        guard width > 0 else { return }
        lastWidth = width
        measuredWidth?.wrappedValue = width
        columnCount = ResponsiveGrid.columnCount(for: width, userSetting: userSetting)
    }
}

@MainActor
struct ResponsiveUserGridModifier: ViewModifier {
    @Binding var columnCount: Int
    @State private var lastWidth: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            updateColumnCount(for: proxy.size.width)
                        }
                        .onChange(of: proxy.size.width) { _, newWidth in
                            updateColumnCount(for: newWidth)
                        }
                }
            )
    }

    private func updateColumnCount(for width: CGFloat) {
        guard width > 0 else { return }
        lastWidth = width
        columnCount = ResponsiveGrid.userColumnCount(for: width)
    }
}

@MainActor
extension View {
    func responsiveGridColumnCount(
        userSetting: UserSetting? = nil,
        columnCount: Binding<Int>,
        measuredWidth: Binding<CGFloat>? = nil
    ) -> some View {
        modifier(ResponsiveGridModifier(userSetting: userSetting, columnCount: columnCount, measuredWidth: measuredWidth))
    }

    func responsiveUserGridColumnCount(
        columnCount: Binding<Int>
    ) -> some View {
        modifier(ResponsiveUserGridModifier(columnCount: columnCount))
    }
}
