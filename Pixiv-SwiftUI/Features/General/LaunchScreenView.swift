import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        launchBackground
            .ignoresSafeArea()
    }

    private var launchBackground: some View {
        #if os(iOS)
        Color(uiColor: .systemBackground)
        #else
        Color(nsColor: .windowBackgroundColor)
        #endif
    }
}

#Preview {
    LaunchScreenView()
}
