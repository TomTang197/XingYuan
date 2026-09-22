import Foundation

public struct CostPoint: Identifiable {
    public var id = UUID()
    public var day: Int
    public var date: Date
    public var costPerDay: Double
}

public struct OverviewStats {
    public var totalAssetValue: Double
    public var totalDailyCost: Double
    public var activeCount: Int
    public var retiredCount: Int
    public var soldCount: Int
    public var totalCount: Int { activeCount + retiredCount + soldCount }
    
    public var activeRatio: Double {
        totalCount == 0 ? 0 : Double(activeCount) / Double(totalCount)
    }
    public var retiredRatio: Double {
        totalCount == 0 ? 0 : Double(retiredCount) / Double(totalCount)
    }
    public var soldRatio: Double {
        totalCount == 0 ? 0 : Double(soldCount) / Double(totalCount)
    }
}

public struct MonthlyPurchase: Identifiable {
    public var id: String { monthKey }
    public var monthKey: String // e.g. "2026-04" or "4.29"
    public var date: Date
    public var totalAmount: Double
    public var count: Int
}

public struct StatusDistributionItem: Identifiable {
    public var id: String { status.rawValue }
    public var status: AssetStatus
    public var count: Int
    public var amount: Double
    public var percentage: Double
}

public enum AssetCalculator {
    private static let calendar = Calendar.current
    
    /// 计算资产服役/持有天数
    public static func daysInService(for item: AssetItem, asOf: Date = Date()) -> Int {
        let endDate: Date
        switch item.status {
        case .active:
            endDate = asOf
        case .retired:
            endDate = item.retiredDate ?? asOf
        case .sold:
            endDate = item.soldDate ?? asOf
        }
        
        let start = calendar.startOfDay(for: item.purchaseDate)
        let end = calendar.startOfDay(for: endDate)
        let days = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        return max(1, days)
    }
    
    /// 计算净成本 (购入价 + 附加项 - 收益 - 二手回血)
    public static func netCost(for item: AssetItem) -> Double {
        let expenseTotal = item.expenses.reduce(0.0) { $0 + $1.amount }
        let incomeTotal = item.incomes.reduce(0.0) { $0 + $1.amount }
        let soldDeduction = (item.status == .sold) ? (item.soldPrice ?? 0.0) : 0.0
        return item.price + expenseTotal - incomeTotal - soldDeduction
    }
    
    /// 计算当前日均（或次均）成本
    public static func dailyCost(for item: AssetItem, asOf: Date = Date()) -> Double {
        let cost = netCost(for: item)
        if item.rule == .byCount {
            return cost / Double(max(1, item.useCount))
        } else {
            let days = daysInService(for: item, asOf: asOf)
            return cost / Double(days)
        }
    }
    
    /// 目标回本倒计时单位数 (按天规则返回剩余天数，按次规则返回剩余次数)
    public static func targetDaysRemaining(for item: AssetItem, asOf: Date = Date()) -> Int? {
        guard let target = item.targetDailyCost, target > 0 else { return nil }
        let cost = netCost(for: item)
        if cost <= 0 { return 0 } // 已通过收益/卖出完全回本
        
        let requiredUnits = Int(ceil(cost / target))
        let currentUnits: Int
        if item.rule == .byCount {
            currentUnits = item.useCount
        } else {
            currentUnits = daysInService(for: item, asOf: asOf)
        }
        return max(0, requiredUnits - currentUnits)
    }
    
    /// 目标回本所需总单位数 (天数或次数)
    public static func targetTotalUnits(for item: AssetItem) -> Int? {
        guard let target = item.targetDailyCost, target > 0 else { return nil }
        let cost = netCost(for: item)
        if cost <= 0 { return 1 }
        return max(1, Int(ceil(cost / target)))
    }
    
    /// 当前已达成回本的比例 (0.0 ~ 1.0)
    public static func targetProgress(for item: AssetItem, asOf: Date = Date()) -> Double {
        guard let total = targetTotalUnits(for: item) else { return 0.0 }
        let current: Int
        if item.rule == .byCount {
            current = item.useCount
        } else {
            current = daysInService(for: item, asOf: asOf)
        }
        return min(1.0, max(0.0, Double(current) / Double(total)))
    }
    
    /// 是否已达成目标日均
    public static func isTargetAchieved(for item: AssetItem, asOf: Date = Date()) -> Bool {
        guard let remaining = targetDaysRemaining(for: item, asOf: asOf) else { return false }
        return remaining == 0
    }
    
    /// 计算历史日均成本下降衰减曲线 (供详情图表呈现)
    public static func costDecayCurve(for item: AssetItem, samplePoints: Int = 20) -> [CostPoint] {
        let totalDays = daysInService(for: item)
        guard totalDays > 1 else {
            return [CostPoint(day: 1, date: item.purchaseDate, costPerDay: netCost(for: item))]
        }
        
        let step = max(1, totalDays / samplePoints)
        var points: [CostPoint] = []
        let cost = netCost(for: item)
        
        for day in stride(from: 1, through: totalDays, by: step) {
            let pointDate = calendar.date(byAdding: .day, value: day, to: item.purchaseDate) ?? item.purchaseDate
            let perDay = cost / Double(day)
            points.append(CostPoint(day: day, date: pointDate, costPerDay: perDay))
        }
        
        if points.last?.day != totalDays {
            points.append(CostPoint(day: totalDays, date: Date(), costPerDay: cost / Double(totalDays)))
        }
        
        return points
    }
    
    /// 计算全局资产看板指标
    public static func calculateOverview(assets: [AssetItem], asOf: Date = Date()) -> OverviewStats {
        var totalValue: Double = 0
        var totalDaily: Double = 0
        var activeCount = 0
        var retiredCount = 0
        var soldCount = 0
        
        for item in assets {
            switch item.status {
            case .active:
                activeCount += 1
                if !item.excludeFromTotalAssets {
                    totalValue += item.price
                }
                if !item.excludeFromDailyCost {
                    totalDaily += dailyCost(for: item, asOf: asOf)
                }
            case .retired:
                retiredCount += 1
            case .sold:
                soldCount += 1

            }
        }
        
        return OverviewStats(
            totalAssetValue: totalValue,
            totalDailyCost: totalDaily,
            activeCount: activeCount,
            retiredCount: retiredCount,
            soldCount: soldCount
        )
    }
    
    /// 按状态分布统计
    public static func calculateDistribution(assets: [AssetItem]) -> [StatusDistributionItem] {
        let total = Double(max(1, assets.count))
        var items: [StatusDistributionItem] = []
        
        for status in AssetStatus.allCases {
            let filtered = assets.filter { $0.status == status }
            let count = filtered.count
            let amount: Double
            if status == .sold {
                // 卖出损益净额
                amount = filtered.reduce(0.0) { $0 + ($1.price - ($1.soldPrice ?? 0.0)) }
            } else {
                amount = filtered.reduce(0.0) { $0 + $1.price }
            }
            let pct = Double(count) / total
            items.append(StatusDistributionItem(status: status, count: count, amount: amount, percentage: pct))
        }
        
        return items
    }
    
    /// 按月份统计购置总额与频次
    public static func calculateMonthlyPurchases(assets: [AssetItem]) -> [MonthlyPurchase] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        
        var dict: [String: (date: Date, total: Double, count: Int)] = [:]
        
        for item in assets {
            let key = formatter.string(from: item.purchaseDate)
            if let existing = dict[key] {
                dict[key] = (existing.date, existing.total + item.price, existing.count + 1)
            } else {
                dict[key] = (item.purchaseDate, item.price, 1)
            }
        }
        
        return dict.map { (key, val) in
            MonthlyPurchase(monthKey: key, date: val.date, totalAmount: val.total, count: val.count)
        }.sorted { $0.date < $1.date }
    }
}
