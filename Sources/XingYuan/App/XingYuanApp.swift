import SwiftUI
import SwiftData
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            for window in sender.windows where !(window is NSPanel) {
                window.makeKeyAndOrderFront(nil)
                return true
            }
            if let url = URL(string: "xingyuan://open") {
                NSWorkspace.shared.open(url)
            }
        }
        return true
    }
}

@main
struct XingYuanApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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
        WindowGroup(id: "main") {
            MainView()
                .frame(minWidth: 850, minHeight: 560)
                .handlesExternalEvents(preferring: ["main", "open"], allowing: ["*"])
        }
        .handlesExternalEvents(matching: ["main", "open", "*"])
        .modelContainer(sharedModelContainer)
        .defaultSize(width: 1100, height: 720)
        .windowToolbarStyle(.unified)
        .commands {
            SidebarCommands()
        }
        
        Window("星元 · 桌面小组件", id: "desktop-widget") {
            DesktopFloatingWidgetView()
                .modelContainer(sharedModelContainer)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.bottomTrailing)
        
        #if os(macOS)
        MenuBarExtra {
            MenuBarView()
                .modelContainer(sharedModelContainer)
        } label: {
            MenuBarLabelView()
                .modelContainer(sharedModelContainer)
        }
        .menuBarExtraStyle(.window)
        #endif
    }
}
