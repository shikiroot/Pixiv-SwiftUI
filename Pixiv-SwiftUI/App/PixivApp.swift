import SwiftData
import SwiftUI

@main
struct PixivApp: App {
    @State private var initializer = AppInitializer.shared

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environment(initializer.accountStore ?? AccountStore.shared)
                    .environment(initializer.illustStore ?? IllustStore.shared)
                    .environment(initializer.userSettingStore ?? UserSettingStore.shared)
                    .environment(ThemeManager.shared)
                    .modelContainer(DataContainer.shared.modelContainer)

                if initializer.isLaunching || initializer.accountStore == nil || initializer.userSettingStore == nil {
                    LaunchScreenView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: initializer.isLaunching)
            .task {
                await initializer.performInitialization()
            }
        }
    }
}

struct ContentView: View {
    @Environment(AccountStore.self) var accountStore
    @Environment(UserSettingStore.self) var userSettingStore
    #if os(iOS)
    @Environment(\.scenePhase) private var scenePhase
    #endif
    @State private var showTokenRefreshFailedToast: Bool = false

    var body: some View {
        Group {
            if !accountStore.hasAttemptedLogin {
                AuthView(accountStore: accountStore, onGuestMode: {
                    accountStore.markLoginAttempted()
                })
            } else {
                Group {
                    MainTabView(accountStore: accountStore)
                }
                .preferredColorScheme(
                    userSettingStore.userSetting.colorSchemeMode == 1 ? .light :
                    userSettingStore.userSetting.colorSchemeMode == 2 ? .dark : nil
                )
                .toast(
                    isPresented: $showTokenRefreshFailedToast,
                    message: "登录状态已过期，请重新登录",
                    duration: 3.0
                )
            }
        }
        .onChange(of: accountStore.showTokenRefreshFailedToast) { _, newValue in
            showTokenRefreshFailedToast = newValue
        }
        .animation(.easeInOut(duration: 0.3), value: accountStore.isLoggedIn)
        #if os(iOS)
        .onAppear {
            updateAppPreviewProtection()
        }
        .onChange(of: scenePhase) { _, _ in
            updateAppPreviewProtection()
        }
        .onChange(of: userSettingStore.userSetting.blurAppPreviewInBackground) { _, _ in
            updateAppPreviewProtection()
        }
        .onDisappear {
            AppPreviewPrivacyManager.shared.removeAllOverlays()
        }
        #endif
    }

    #if os(iOS)
    private func updateAppPreviewProtection() {
        AppPreviewPrivacyManager.shared.updateProtection(
            isEnabled: userSettingStore.userSetting.blurAppPreviewInBackground,
            scenePhase: scenePhase
        )
    }
    #endif
}

#Preview {
    ContentView()
        .environment(AccountStore.shared)
        .environment(IllustStore())
        .environment(UserSettingStore())
}
