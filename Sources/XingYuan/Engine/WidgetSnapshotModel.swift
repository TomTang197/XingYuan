import Foundation
import AppIntents

public enum WidgetSortRule: String, AppEnum, Codable, CaseIterable {
    case lowestDaily
    case highestDaily
    case newest
    case oldest
    case highestPrice
    case lowestPrice
    
    public static var typeDisplayRepresentation: TypeDisplayRepresentation = "排序规则"
    
    public static var caseDisplayRepresentations: [WidgetSortRule: DisplayRepresentation] = [
        .lowestDaily: "最低每日 (物超所值)",
        .highestDaily: "最高每日 (耗资最大)",
        .newest: "最新购买",
        .oldest: "最旧服役",
        .highestPrice: "最高原价",
        .lowestPrice: "最低原价"
    ]
    
    public var shortTitle: String {
        switch self {
        case .lowestDaily: return "最低每日"
        case .highestDaily: return "最高每日"
        case .newest: return "最新购买"
        case .oldest: return "服役最久"
        case .highestPrice: return "最高原价"
        case .lowestPrice: return "最低原价"
        }
    }
    
    public var topTitle: String {
        switch self {
        case .lowestDaily: return "物超所值 Top 5"
        case .highestDaily: return "耗资最大 Top 5"
        case .newest: return "最新入手 Top 5"
        case .oldest: return "陪伴最久 Top 5"
        case .highestPrice: return "原价最高 Top 5"
        case .lowestPrice: return "原价最低 Top 5"
        }
    }
    
    public var subtitle: String {
        switch self {
        case .lowestDaily: return "最低每日成本"
        case .highestDaily: return "最高每日成本"
        case .newest: return "按入手时间排序"
        case .oldest: return "按服役天数排序"
        case .highestPrice: return "按买入原价排序"
        case .lowestPrice: return "按买入原价排序"
        }
    }
}

public struct WidgetAssetItem: Codable, Identifiable {
    public var id: UUID
    public var name: String
    public var iconName: String
    public var daysInService: Int
    public var dailyCost: Double
    public var price: Double
    public var purchaseDate: Date
    public var category: String
    
    public init(
        id: UUID = UUID(),
        name: String,
        iconName: String,
        daysInService: Int,
        dailyCost: Double,
        price: Double = 0.0,
        purchaseDate: Date = Date(),
        category: String
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.daysInService = daysInService
        self.dailyCost = dailyCost
        self.price = price
        self.purchaseDate = purchaseDate
        self.category = category
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, iconName, daysInService, dailyCost, price, purchaseDate, category
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        iconName = try container.decodeIfPresent(String.self, forKey: .iconName) ?? "cube.box"
        daysInService = try container.decodeIfPresent(Int.self, forKey: .daysInService) ?? 1
        dailyCost = try container.decodeIfPresent(Double.self, forKey: .dailyCost) ?? 0.0
        price = try container.decodeIfPresent(Double.self, forKey: .price) ?? 0.0
        purchaseDate = try container.decodeIfPresent(Date.self, forKey: .purchaseDate) ?? Date()
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? "默认"
    }
}

public struct WidgetSnapshotData: Codable {
    public var totalDailyCost: Double
    public var totalAssetValue: Double
    public var activeCount: Int
    public var totalCount: Int
    public var topAssets: [WidgetAssetItem]
    public var allActiveAssets: [WidgetAssetItem]
    public var defaultSortRule: WidgetSortRule
    public var updatedAt: Date
    
    public init(
        totalDailyCost: Double = 0.0,
        totalAssetValue: Double = 0.0,
        activeCount: Int = 0,
        totalCount: Int = 0,
        topAssets: [WidgetAssetItem] = [],
        allActiveAssets: [WidgetAssetItem] = [],
        defaultSortRule: WidgetSortRule = .lowestDaily,
        updatedAt: Date = Date()
    ) {
        self.totalDailyCost = totalDailyCost
        self.totalAssetValue = totalAssetValue
        self.activeCount = activeCount
        self.totalCount = totalCount
        self.topAssets = topAssets
        self.allActiveAssets = allActiveAssets
        self.defaultSortRule = defaultSortRule
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case totalDailyCost, totalAssetValue, activeCount, totalCount, topAssets, allActiveAssets, defaultSortRule, updatedAt
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalDailyCost = try container.decodeIfPresent(Double.self, forKey: .totalDailyCost) ?? 0.0
        totalAssetValue = try container.decodeIfPresent(Double.self, forKey: .totalAssetValue) ?? 0.0
        activeCount = try container.decodeIfPresent(Int.self, forKey: .activeCount) ?? 0
        totalCount = try container.decodeIfPresent(Int.self, forKey: .totalCount) ?? 0
        topAssets = try container.decodeIfPresent([WidgetAssetItem].self, forKey: .topAssets) ?? []
        allActiveAssets = try container.decodeIfPresent([WidgetAssetItem].self, forKey: .allActiveAssets) ?? []
        defaultSortRule = try container.decodeIfPresent(WidgetSortRule.self, forKey: .defaultSortRule) ?? .lowestDaily
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
    }
    
    public func sortedAssets(for rule: WidgetSortRule, limit: Int = 5) -> [WidgetAssetItem] {
        let pool = allActiveAssets.isEmpty ? topAssets : allActiveAssets
        let sorted: [WidgetAssetItem]
        switch rule {
        case .lowestDaily:
            sorted = pool.sorted { $0.dailyCost < $1.dailyCost }
        case .highestDaily:
            sorted = pool.sorted { $0.dailyCost > $1.dailyCost }
        case .newest:
            sorted = pool.sorted { $0.purchaseDate > $1.purchaseDate }
        case .oldest:
            sorted = pool.sorted { $0.purchaseDate < $1.purchaseDate }
        case .highestPrice:
            sorted = pool.sorted { $0.price > $1.price }
        case .lowestPrice:
            sorted = pool.sorted { $0.price < $1.price }
        }
        return Array(sorted.prefix(limit))
    }
    
    public static var placeholder: WidgetSnapshotData {
        let cal = Calendar.current
        let now = Date()
        let items: [WidgetAssetItem] = [
            WidgetAssetItem(name: "爱否 F1", iconName: "cube.box.fill", daysInService: 2682, dailyCost: 0.06, price: 168.99, purchaseDate: cal.date(byAdding: .day, value: -2682, to: now) ?? now, category: "居家"),
            WidgetAssetItem(name: "AirPods pro 2", iconName: "airpodspro", daysInService: 1783, dailyCost: 0.97, price: 1724.00, purchaseDate: cal.date(byAdding: .day, value: -1783, to: now) ?? now, category: "影音"),
            WidgetAssetItem(name: "Hagis 380w", iconName: "powerplug.fill", daysInService: 84, dailyCost: 4.12, price: 350.00, purchaseDate: cal.date(byAdding: .day, value: -84, to: now) ?? now, category: "数码"),
            WidgetAssetItem(name: "iPad pro m1", iconName: "ipad", daysInService: 1473, dailyCost: 5.80, price: 8548.00, purchaseDate: cal.date(byAdding: .day, value: -1473, to: now) ?? now, category: "数码"),
            WidgetAssetItem(name: "iPhone 13 Pro Max", iconName: "iphone", daysInService: 1796, dailyCost: 6.57, price: 11799.00, purchaseDate: cal.date(byAdding: .day, value: -1796, to: now) ?? now, category: "数码"),
            WidgetAssetItem(name: "AirPods pro 3", iconName: "airpodspro", daysInService: 175, dailyCost: 8.91, price: 1560.00, purchaseDate: cal.date(byAdding: .day, value: -175, to: now) ?? now, category: "影音"),
            WidgetAssetItem(name: "Fiat 2015", iconName: "car.fill", daysInService: 1243, dailyCost: 27.35, price: 34000.00, purchaseDate: cal.date(byAdding: .day, value: -1243, to: now) ?? now, category: "出行"),
            WidgetAssetItem(name: "MBP m4m", iconName: "laptopcomputer", daysInService: 38, dailyCost: 631.58, price: 24000.00, purchaseDate: cal.date(byAdding: .day, value: -38, to: now) ?? now, category: "办公")
        ]
        
        return WidgetSnapshotData(
            totalDailyCost: 669.09,
            totalAssetValue: 82149.99,
            activeCount: 8,
            totalCount: 10,
            topAssets: Array(items.prefix(5)),
            allActiveAssets: items,
            defaultSortRule: .lowestDaily,
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
