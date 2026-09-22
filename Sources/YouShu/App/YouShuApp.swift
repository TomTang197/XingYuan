import SwiftUI
import SwiftData

@main
struct YouShuApp: App {
    private var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            AssetItem.self,
            WishItem.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("无法初始化 SwiftData ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .frame(minWidth: 850, minHeight: 560)
        }
        .modelContainer(sharedModelContainer)
        .defaultSize(width: 1100, height: 720)
        .windowToolbarStyle(.unified)
        .commands {
            SidebarCommands()
        }
        
        #if os(macOS)
        MenuBarExtra("有数", systemImage: "bolt.circle.fill") {
            MenuBarView()
                .modelContainer(sharedModelContainer)
        }
        .menuBarExtraStyle(.window)
        #endif
    }
}
