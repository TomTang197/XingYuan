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
            totalDailyCost: 669.09,
            totalAssetValue: 82149.99,
            activeCount: 8,
            totalCount: 10,
            topAssets: [
                WidgetAssetItem(name: "爱否 F1", iconName: "cube.box.fill", daysInService: 2683, dailyCost: 0.06, category: "居家"),
                WidgetAssetItem(name: "AirPods pro 2", iconName: "airpodspro", daysInService: 1784, dailyCost: 0.97, category: "影音"),
                WidgetAssetItem(name: "Hagis 380w", iconName: "powerplug.fill", daysInService: 85, dailyCost: 4.12, category: "数码")
            ],
            updatedAt: Date()
        )
    }
}

public enum WidgetDataReader {
    public static var containerDocumentsURL: URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appendingPathComponent("Library/Containers/com.xingyuan.costperday.desktopwidget/Data/Documents", isDirectory: true)
    }
    
    public static var sharedFileURL: URL {
        if let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = docs.appendingPathComponent("widget_data.json")
            if FileManager.default.fileExists(atPath: path.path) {
                return path
            }
        }
        return containerDocumentsURL.appendingPathComponent("widget_data.json")
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
