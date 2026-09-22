import XCTest
@testable import YouShu

final class AssetCalculatorTests: XCTestCase {
    private let calendar = Calendar.current
    
    func testActiveAssetDailyCost() {
        let purchaseDate = calendar.date(byAdding: .day, value: -100, to: Date())!
        let asset = AssetItem(
            name: "Test Mac",
            price: 10000.0,
            purchaseDate: purchaseDate,
            status: .active
        )
        
        XCTAssertEqual(AssetCalculator.daysInService(for: asset), 100)
        XCTAssertEqual(AssetCalculator.dailyCost(for: asset), 100.0, accuracy: 0.01)
    }
    
    func testSoldAssetWithResidualValue() {
        let purchaseDate = calendar.date(byAdding: .day, value: -200, to: Date())!
        let soldDate = calendar.date(byAdding: .day, value: -100, to: Date())!
        let asset = AssetItem(
            name: "iPhone",
            price: 6000.0,
            purchaseDate: purchaseDate,
            status: .sold,
            soldDate: soldDate,
            soldPrice: 3000.0
        )
        
        XCTAssertEqual(AssetCalculator.daysInService(for: asset), 100)
        // Net cost = 6000 - 3000 = 3000; days = 100 -> Daily = 30
        XCTAssertEqual(AssetCalculator.netCost(for: asset), 3000.0, accuracy: 0.01)
        XCTAssertEqual(AssetCalculator.dailyCost(for: asset), 30.0, accuracy: 0.01)
    }
    
    func testByCountRuleCalculation() {
        let asset = AssetItem(
            name: "健身私教课",
            price: 5000.0,
            purchaseDate: Date(),
            rule: .byCount,
            useCount: 25,
            targetDailyCost: 100.0 // 目标每次 100 元
        )
        
        // 5000 / 25 = 200/次
        XCTAssertEqual(AssetCalculator.dailyCost(for: asset), 200.0, accuracy: 0.01)
        // 总需 5000 / 100 = 50次，已使用 25次 -> 还剩 25次
        XCTAssertEqual(AssetCalculator.targetDaysRemaining(for: asset), 25)
        XCTAssertEqual(AssetCalculator.targetProgress(for: asset), 0.5, accuracy: 0.01)
        XCTAssertFalse(AssetCalculator.isTargetAchieved(for: asset))
    }
    
    func testTargetDaysCountdownAndProgress() {
        let purchaseDate = calendar.date(byAdding: .day, value: -30, to: Date())!
        let asset = AssetItem(
            name: "Headphones",
            price: 1000.0,
            purchaseDate: purchaseDate,
            status: .active,
            targetDailyCost: 10.0 // Needs 1000 / 10 = 100 days
        )
        
        // 100 - 30 = 70 days left
        XCTAssertEqual(AssetCalculator.targetDaysRemaining(for: asset), 70)
        XCTAssertEqual(AssetCalculator.targetProgress(for: asset), 0.3, accuracy: 0.01)
        XCTAssertFalse(AssetCalculator.isTargetAchieved(for: asset))
    }
    
    func testTargetAchievedWhenFullyDepreciated() {
        let purchaseDate = calendar.date(byAdding: .day, value: -120, to: Date())!
        let asset = AssetItem(
            name: "Keyboard",
            price: 1000.0,
            purchaseDate: purchaseDate,
            status: .active,
            targetDailyCost: 10.0 // Needs 100 days, has been 120 days
        )
        
        XCTAssertEqual(AssetCalculator.targetDaysRemaining(for: asset), 0)
        XCTAssertEqual(AssetCalculator.targetProgress(for: asset), 1.0, accuracy: 0.01)
        XCTAssertTrue(AssetCalculator.isTargetAchieved(for: asset))
    }
    
    func testExpensesAndIncomesInNetCost() {
        let asset = AssetItem(
            name: "Camera",
            price: 10000.0,
            purchaseDate: calendar.date(byAdding: .day, value: -50, to: Date())!,
            expenses: [
                FinancialRecord(title: "额外镜头", amount: 3000.0),
                FinancialRecord(title: "清洁套装", amount: 200.0)
            ],
            incomes: [
                FinancialRecord(title: "商业拍摄出租回血", amount: 1200.0)
            ]
        )
        
        // Net = 10000 + 3200 - 1200 = 12000
        XCTAssertEqual(AssetCalculator.netCost(for: asset), 12000.0, accuracy: 0.01)
        // 12000 / 50 = 240/天
        XCTAssertEqual(AssetCalculator.dailyCost(for: asset), 240.0, accuracy: 0.01)
    }
    
    func testBoughtTodayZeroDaysSafeguard() {
        let asset = AssetItem(
            name: "刚刚买的咖啡机",
            price: 365.0,
            purchaseDate: Date()
        )
        
        // 当日购入应规整为至少 1 天，防止除以零崩溃
        XCTAssertEqual(AssetCalculator.daysInService(for: asset), 1)
        XCTAssertEqual(AssetCalculator.dailyCost(for: asset), 365.0, accuracy: 0.01)
    }
    
    func testRetiredAssetCostLocking() {
        let purchaseDate = calendar.date(byAdding: .day, value: -300, to: Date())!
        let retiredDate = calendar.date(byAdding: .day, value: -100, to: Date())!
        let asset = AssetItem(
            name: "老旧电风扇",
            price: 200.0,
            purchaseDate: purchaseDate,
            status: .retired,
            retiredDate: retiredDate
        )
        
        // 服役时间应锁定在 300 - 100 = 200 天，不再随今天时间增加
        XCTAssertEqual(AssetCalculator.daysInService(for: asset), 200)
        XCTAssertEqual(AssetCalculator.dailyCost(for: asset), 1.0, accuracy: 0.01)
    }
    
    func testOverviewStatsExclusionSwitches() {
        let normalItem = AssetItem(
            name: "Normal Mac",
            price: 10000.0,
            purchaseDate: calendar.date(byAdding: .day, value: -10, to: Date())!
        )
        let excludedTotalItem = AssetItem(
            name: "赠品 iPad",
            price: 5000.0,
            purchaseDate: calendar.date(byAdding: .day, value: -10, to: Date())!,
            excludeFromTotalAssets: true
        )
        let excludedDailyItem = AssetItem(
            name: "收藏品腕表",
            price: 30000.0,
            purchaseDate: calendar.date(byAdding: .day, value: -10, to: Date())!,
            excludeFromDailyCost: true
        )
        
        let stats = AssetCalculator.calculateOverview(assets: [normalItem, excludedTotalItem, excludedDailyItem])
        
        // Total asset value should exclude excludedTotalItem: 10000 + 30000 = 40000
        XCTAssertEqual(stats.totalAssetValue, 40000.0, accuracy: 0.01)
        // Total daily should exclude excludedDailyItem: normal (10000/10=1000) + excludedTotal (5000/10=500) = 1500
        XCTAssertEqual(stats.totalDailyCost, 1500.0, accuracy: 0.01)
        XCTAssertEqual(stats.activeCount, 3)
    }
    
    func testCostDecayCurveMonotonicity() {
        let asset = AssetItem(
            name: "MacBook",
            price: 24000.0,
            purchaseDate: calendar.date(byAdding: .day, value: -100, to: Date())!
        )
        
        let curve = AssetCalculator.costDecayCurve(for: asset, samplePoints: 10)
        XCTAssertGreaterThan(curve.count, 1)
        
        // 衰减曲线上的每一天成本应当单调递减
        for i in 1..<curve.count {
            XCTAssertLessThanOrEqual(curve[i].costPerDay, curve[i - 1].costPerDay)
        }
    }
}
