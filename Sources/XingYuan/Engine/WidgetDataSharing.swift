import Foundation
import WidgetKit

public enum WidgetDataSharing {
    /// 从当前资产库生成快照并持久化，同时通知 WidgetKit 刷新
    public static func syncSnapshot(from assets: [AssetItem]) {
        let stats = AssetCalculator.calculateOverview(assets: assets, filterStatus: .active)
        
        let activeItems = assets
            .filter { $0.status == .active }
            .sorted { AssetCalculator.dailyCost(for: $0) < AssetCalculator.dailyCost(for: $1) }
        
        let topAssets: [WidgetAssetItem] = activeItems.prefix(5).map { item in
            WidgetAssetItem(
                id: item.id,
                name: item.name,
                iconName: item.iconName,
                daysInService: AssetCalculator.daysInService(for: item),
                dailyCost: AssetCalculator.dailyCost(for: item),
                category: item.category
            )
        }
        
        let snapshot = WidgetSnapshotData(
            totalDailyCost: stats.totalDailyCost,
            totalAssetValue: stats.totalAssetValue,
            activeCount: stats.activeCount,
            totalCount: assets.count,
            topAssets: topAssets,
            updatedAt: Date()
        )
        
        saveSnapshot(snapshot)
        
        // 唤醒系统小组件刷新
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    /// 将快照写入小组件容器存储
    public static func saveSnapshot(_ snapshot: WidgetSnapshotData) {
        do {
            let dir = WidgetDataReader.containerDocumentsURL
            if !FileManager.default.fileExists(atPath: dir.path) {
                try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            }
            let fileURL = dir.appendingPathComponent("widget_data.json")
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(snapshot)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("[WidgetDataSharing] 写入快照失败: \(error)")
        }
    }
}
