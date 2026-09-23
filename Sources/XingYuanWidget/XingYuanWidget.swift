import WidgetKit
import SwiftUI

struct XingYuanEntry: TimelineEntry {
    let date: Date
    let data: WidgetSnapshotData
}

struct XingYuanProvider: TimelineProvider {
    func placeholder(in context: Context) -> XingYuanEntry {
        XingYuanEntry(date: Date(), data: .placeholder)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (XingYuanEntry) -> Void) {
        let snapshot = WidgetDataReader.readSnapshot()
        completion(XingYuanEntry(date: Date(), data: snapshot))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<XingYuanEntry>) -> Void) {
        let snapshot = WidgetDataReader.readSnapshot()
        let currentDate = Date()
        let entry = XingYuanEntry(date: currentDate, data: snapshot)
        // Refresh every 30 minutes, or when main app pushes updates
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate) ?? currentDate.addingTimeInterval(1800)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct XingYuanWidget: Widget {
    let kind: String = "com.xingyuan.costperday.widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: XingYuanProvider()) { entry in
            XingYuanWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("星元追踪")
        .description("无需打开应用，实时追踪今日在役资产总日均与物超所值物品。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
