import Foundation
import SwiftData

public struct ExportPayload: Codable {
    public struct ExportAsset: Codable {
        public var id: UUID
        public var name: String
        public var price: Double
        public var purchaseDate: Date
        public var category: String
        public var tags: [String]
        public var iconName: String
        public var status: String
        public var rule: String
        public var useCount: Int
        public var targetDailyCost: Double?
        public var targetDate: Date?
        public var retiredDate: Date?
        public var soldDate: Date?
        public var soldPrice: Double?
        public var marketPrice: Double?
        public var isPinned: Bool
        public var excludeFromTotalAssets: Bool
        public var excludeFromDailyCost: Bool
        public var notes: String
        public var expenses: [FinancialRecord]
        public var incomes: [FinancialRecord]
    }
    
    public struct ExportWish: Codable {
        public var id: UUID
        public var name: String
        public var estimatedPrice: Double
        public var category: String
        public var tags: [String]
        public var iconName: String
        public var targetDailyCost: Double?
        public var notes: String
    }
    
    public var version: String = "1.0"
    public var exportedAt: Date = Date()
    public var assets: [ExportAsset]
    public var wishes: [ExportWish]
}

public enum DataExporter {
    public static func exportToJSON(assets: [AssetItem], wishes: [WishItem]) throws -> Data {
        let exportAssets = assets.map {
            ExportPayload.ExportAsset(
                id: $0.id,
                name: $0.name,
                price: $0.price,
                purchaseDate: $0.purchaseDate,
                category: $0.category,
                tags: $0.tags,
                iconName: $0.iconName,
                status: $0.statusRaw,
                rule: $0.ruleRaw,
                useCount: $0.useCount,
                targetDailyCost: $0.targetDailyCost,
                targetDate: $0.targetDate,
                retiredDate: $0.retiredDate,
                soldDate: $0.soldDate,
                soldPrice: $0.soldPrice,
                marketPrice: $0.marketPrice,
                isPinned: $0.isPinned,
                excludeFromTotalAssets: $0.excludeFromTotalAssets,
                excludeFromDailyCost: $0.excludeFromDailyCost,
                notes: $0.notes,
                expenses: $0.expenses,
                incomes: $0.incomes
            )
        }
        
        let exportWishes = wishes.map {
            ExportPayload.ExportWish(
                id: $0.id,
                name: $0.name,
                estimatedPrice: $0.estimatedPrice,
                category: $0.category,
                tags: $0.tags,
                iconName: $0.iconName,
                targetDailyCost: $0.targetDailyCost,
                notes: $0.notes
            )
        }
        
        let payload = ExportPayload(assets: exportAssets, wishes: exportWishes)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(payload)
    }
    
    public static func exportToCSV(assets: [AssetItem]) -> String {
        var lines = ["名称,价格,购买日期,状态,服役天数,当前日均成本,类别,标签,备注"]
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        
        for item in assets {
            let days = AssetCalculator.daysInService(for: item)
            let daily = AssetCalculator.dailyCost(for: item)
            let line = [
                "\"\(item.name)\"",
                String(format: "%.2f", item.price),
                df.string(from: item.purchaseDate),
                item.status.title,
                "\(days)",
                String(format: "%.2f", daily),
                "\"\(item.category)\"",
                "\"\(item.tags.joined(separator: ";"))\"",
                "\"\(item.notes.replacingOccurrences(of: "\"", with: "\"\""))\""
            ].joined(separator: ",")
            lines.append(line)
        }
        
        return lines.joined(separator: "\n")
    }
    
    public static func importFromJSON(data: Data, context: ModelContext) throws -> (assetCount: Int, wishCount: Int) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(ExportPayload.self, from: data)
        
        for a in payload.assets {
            let item = AssetItem(
                id: a.id,
                name: a.name,
                price: a.price,
                purchaseDate: a.purchaseDate,
                category: a.category,
                tags: a.tags,
                iconName: a.iconName,
                status: AssetStatus(rawValue: a.status) ?? .active,
                rule: CostRule(rawValue: a.rule) ?? .byDay,
                useCount: a.useCount,
                targetDailyCost: a.targetDailyCost,
                targetDate: a.targetDate,
                retiredDate: a.retiredDate,
                soldDate: a.soldDate,
                soldPrice: a.soldPrice,
                marketPrice: a.marketPrice,
                isPinned: a.isPinned,
                excludeFromTotalAssets: a.excludeFromTotalAssets,
                excludeFromDailyCost: a.excludeFromDailyCost,
                notes: a.notes,
                expenses: a.expenses,
                incomes: a.incomes
            )
            context.insert(item)
        }
        
        for w in payload.wishes {
            let wish = WishItem(
                id: w.id,
                name: w.name,
                estimatedPrice: w.estimatedPrice,
                category: w.category,
                tags: w.tags,
                iconName: w.iconName,
                targetDailyCost: w.targetDailyCost,
                notes: w.notes
            )
            context.insert(wish)
        }
        
        try context.save()
        return (payload.assets.count, payload.wishes.count)
    }
}
