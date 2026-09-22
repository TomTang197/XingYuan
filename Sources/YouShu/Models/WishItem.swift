import Foundation
import SwiftData

@Model
public final class WishItem {
    public var id: UUID
    public var name: String
    public var estimatedPrice: Double
    public var category: String
    public var tags: [String]
    public var iconName: String
    public var targetDailyCost: Double?
    public var notes: String
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        estimatedPrice: Double,
        category: String = "数码",
        tags: [String] = [],
        iconName: String = "sparkles",
        targetDailyCost: Double? = nil,
        notes: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.estimatedPrice = estimatedPrice
        self.category = category
        self.tags = tags
        self.iconName = iconName
        self.targetDailyCost = targetDailyCost
        self.notes = notes
        self.createdAt = createdAt
    }
}
