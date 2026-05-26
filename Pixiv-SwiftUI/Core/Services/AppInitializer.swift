import SwiftUI
import Observation

/// 应用启动初始化器，负责协调启动过程中的各种任务
@MainActor
@Observable
final class AppInitializer {
    static let shared = AppInitializer()

    var isLaunching = true
    var accountStore: AccountStore?
    var illustStore: IllustStore?
    var userSettingStore: UserSettingStore?
    private var hasInitialized = false

    private init() {}

    /// 执行应用初始化序列
    func performInitialization() async {
        guard !hasInitialized else { return }
        hasInitialized = true

        // 1. 配置基础服务
        CacheConfig.configureKingfisher()
        UgoiraStore.cleanupLegacyCache()

        // 2. 初始化核心 Store
        let aStore = AccountStore.shared
        let iStore = IllustStore.shared
        let uStore = UserSettingStore.shared

        // 3. 异步加载持久化数据
        // 用户设置依赖当前账户 ownerId，必须在账户恢复后再加载。
        await aStore.loadAccountsAsync()
        await uStore.loadUserSettingAsync()

        // 4. 更新初始化状态
        self.accountStore = aStore
        self.illustStore = iStore
        self.userSettingStore = uStore

        // 5. 延迟结束启动占位，避免初始化完成前短暂露出登录页
        try? await Task.sleep(for: .milliseconds(180))

        // 6. 进入正常显示状态
        AccountStore.shared.markLoginAttempted()
        withAnimation(.easeInOut(duration: 0.2)) {
            self.isLaunching = false
        }

        // 7. 检查更新（后台执行）
        checkForUpdateOnLaunch()
    }

    private func checkForUpdateOnLaunch() {
        guard userSettingStore?.userSetting.checkUpdateOnLaunch == true else { return }

        Task {
            if let updateInfo = await UpdateChecker.shared.checkForUpdate() {
                await MainActor.run {
                    if updateInfo.isNewerThanCurrent {
                        NotificationCenter.default.post(
                            name: .init("ShowUpdateNotification"),
                            object: updateInfo
                        )
                    }
                }
            }
        }
    }
}
