import Foundation
import SwiftData

@Model
public final class AssetItem {
    public var id: UUID
    public var name: String
    public var price: Double
    public var purchaseDate: Date
    public var category: String
    public var tags: [String]
    public var iconName: String
    
    // 状态与规则
    public var statusRaw: String
    public var ruleRaw: String
    public var useCount: Int
    
    // 目标与生命周期
    public var targetDailyCost: Double?
    public var targetDate: Date?
    public var retiredDate: Date?
    public var soldDate: Date?
    public var soldPrice: Double?
    public var marketPrice: Double?
    
    // 开关
    public var isPinned: Bool
    public var excludeFromTotalAssets: Bool
    public var excludeFromDailyCost: Bool
    public var notes: String
    
    // 附加项与收益记录
    public var expenses: [FinancialRecord]
    public var incomes: [FinancialRecord]
    
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        price: Double,
        purchaseDate: Date = Date(),
        category: String = "数码",
        tags: [String] = [],
        iconName: String = "shippingbox.fill",
        status: AssetStatus = .active,
        rule: CostRule = .byDay,
        useCount: Int = 1,
        targetDailyCost: Double? = nil,
        targetDate: Date? = nil,
        retiredDate: Date? = nil,
        soldDate: Date? = nil,
        soldPrice: Double? = nil,
        marketPrice: Double? = nil,
        isPinned: Bool = false,
        excludeFromTotalAssets: Bool = false,
        excludeFromDailyCost: Bool = false,
        notes: String = "",
        expenses: [FinancialRecord] = [],
        incomes: [FinancialRecord] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.purchaseDate = purchaseDate
        self.category = category
        self.tags = tags
        self.iconName = iconName
        self.statusRaw = status.rawValue
        self.ruleRaw = rule.rawValue
        self.useCount = useCount
        self.targetDailyCost = targetDailyCost
        self.targetDate = targetDate
        self.retiredDate = retiredDate
        self.soldDate = soldDate
        self.soldPrice = soldPrice
        self.marketPrice = marketPrice
        self.isPinned = isPinned
        self.excludeFromTotalAssets = excludeFromTotalAssets
        self.excludeFromDailyCost = excludeFromDailyCost
        self.notes = notes
        self.expenses = expenses
        self.incomes = incomes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public var status: AssetStatus {
        get { AssetStatus(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }
    
    public var rule: CostRule {
        get { CostRule(rawValue: ruleRaw) ?? .byDay }
        set { ruleRaw = newValue.rawValue }
    }
}
