import WidgetKit
import SwiftUI
import AppIntents

struct XingYuanEntry: TimelineEntry {
    let date: Date
    let data: WidgetSnapshotData
    let sortRule: WidgetSortRule
}

// MARK: - Static Timeline Provider (Auto-syncs with App / MenuBar preference)
struct XingYuanStaticProvider: TimelineProvider {
    func placeholder(in context: Context) -> XingYuanEntry {
        XingYuanEntry(date: Date(), data: .placeholder, sortRule: .lowestDaily)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (XingYuanEntry) -> Void) {
        let snapshot = WidgetDataReader.readSnapshot()
        completion(XingYuanEntry(date: Date(), data: snapshot, sortRule: snapshot.defaultSortRule))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<XingYuanEntry>) -> Void) {
        let snapshot = WidgetDataReader.readSnapshot()
        let currentDate = Date()
        let entry = XingYuanEntry(date: currentDate, data: snapshot, sortRule: snapshot.defaultSortRule)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate) ?? currentDate.addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

// MARK: - AppIntent Timeline Provider (Independently configurable per widget instance)
struct XingYuanAppIntentProvider: AppIntentTimelineProvider {
    typealias Entry = XingYuanEntry
    typealias Intent = SelectSortRuleIntent
    
    func placeholder(in context: Context) -> XingYuanEntry {
        XingYuanEntry(date: Date(), data: .placeholder, sortRule: .lowestDaily)
    }
    
    func snapshot(for configuration: SelectSortRuleIntent, in context: Context) async -> XingYuanEntry {
        let snapshot = WidgetDataReader.readSnapshot()
        return XingYuanEntry(date: Date(), data: snapshot, sortRule: configuration.sortRule)
    }
    
    func timeline(for configuration: SelectSortRuleIntent, in context: Context) async -> Timeline<XingYuanEntry> {
        let snapshot = WidgetDataReader.readSnapshot()
        let currentDate = Date()
        let entry = XingYuanEntry(date: currentDate, data: snapshot, sortRule: configuration.sortRule)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate) ?? currentDate.addingTimeInterval(1800)
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

// MARK: - Default Widget (Auto-sync with App & MenuBar)
struct XingYuanDesktopWidget: Widget {
    let kind: String = "XingYuanDesktopWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: XingYuanStaticProvider()) { entry in
            XingYuanWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("星元")
        .description("实时追踪在役资产日均成本，自动同步全局与菜单栏排序偏好。")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Configurable Widget (Allows custom sorting per desktop widget instance)
struct XingYuanCustomWidget: Widget {
    let kind: String = "XingYuanCustomWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectSortRuleIntent.self, provider: XingYuanAppIntentProvider()) { entry in
            XingYuanWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("星元 (独立排序)")
        .description("右键点击小组件可独立挑选排序视角（最新/最高价/最高每日等）。")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
