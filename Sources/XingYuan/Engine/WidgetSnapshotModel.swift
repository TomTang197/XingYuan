import Foundation

public struct WidgetAssetItem: Codable, Identifiable {
    public var id: UUID
    public var name: String
    public var iconName: String
    public var daysInService: Int
    public var dailyCost: Double
    public var category: String
    
    public init(
        id: UUID = UUID(),
        name: String,
        iconName: String,
        daysInService: Int,
        dailyCost: Double,
        category: String
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.daysInService = daysInService
        self.dailyCost = dailyCost
        self.category = category
    }
}

public struct WidgetSnapshotData: Codable {
    public var totalDailyCost: Double
    public var totalAssetValue: Double
    public var activeCount: Int
    public var totalCount: Int
    public var topAssets: [WidgetAssetItem]
    public var updatedAt: Date
    
    public init(
        totalDailyCost: Double = 0.0,
        totalAssetValue: Double = 0.0,
        activeCount: Int = 0,
        totalCount: Int = 0,
        topAssets: [WidgetAssetItem] = [],
        updatedAt: Date = Date()
    ) {
        self.totalDailyCost = totalDailyCost
        self.totalAssetValue = totalAssetValue
        self.activeCount = activeCount
        self.totalCount = totalCount
        self.topAssets = topAssets
        self.updatedAt = updatedAt
    }
    
    public static var placeholder: WidgetSnapshotData {
        WidgetSnapshotData(
            totalDailyCost: 685.42,
            totalAssetValue: 82149.99,
            activeCount: 8,
            totalCount: 10,
            topAssets: [
                WidgetAssetItem(name: "Sony A7M4", iconName: "camera.fill", daysInService: 450, dailyCost: 35.5, category: "数码"),
                WidgetAssetItem(name: "MacBook Pro", iconName: "laptopcomputer", daysInService: 280, dailyCost: 42.8, category: "办公"),
                WidgetAssetItem(name: "Hermes 表带", iconName: "applewatch", daysInService: 120, dailyCost: 15.0, category: "穿搭")
            ],
            updatedAt: Date()
        )
    }
}

public enum WidgetDataReader {
    public static var sharedFileURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("XingYuan", isDirectory: true)
        return dir.appendingPathComponent("widget_data.json")
    }
    
    public static func readSnapshot() -> WidgetSnapshotData {
        guard let data = try? Data(contentsOf: sharedFileURL) else {
            return .placeholder
        }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(WidgetSnapshotData.self, from: data)
        } catch {
            return .placeholder
        }
    }
}
