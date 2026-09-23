import XCTest
@testable import XingYuan

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
    
    func testSoldOutcomeScenarios() {
        let purchaseDate = calendar.date(byAdding: .day, value: -30, to: Date())!
        let soldDate = Date()
        
        // 场景 1: 溢价卖出 (理财盈利，售出价高于投入)
        let profitItem = AssetItem(
            name: "MBP m2p",
            price: 1832.0,
            purchaseDate: purchaseDate,
            status: .sold,
            soldDate: soldDate,
            soldPrice: 2000.0
        )
        XCTAssertEqual(AssetCalculator.grossCost(for: profitItem), 1832.0, accuracy: 0.01)
        XCTAssertEqual(AssetCalculator.netCost(for: profitItem), -168.0, accuracy: 0.01)
        XCTAssertEqual(AssetCalculator.dailyCost(for: profitItem), -168.0 / 30.0, accuracy: 0.01)
        XCTAssertEqual(AssetCalculator.soldOutcome(for: profitItem), .profit(profitAmount: 168.0))
        XCTAssertTrue(AssetCalculator.soldOutcome(for: profitItem).isProfit)
        XCTAssertEqual(AssetCalculator.recoveryRate(for: profitItem)!, 2000.0 / 1832.0, accuracy: 0.001)
        
        // 场景 2: 平价脱手 (0元白嫖，售出价等于投入)
        let breakEvenItem = AssetItem(
            name: "mbp m5",
            price: 2000.0,
            purchaseDate: purchaseDate,
            status: .sold,
            soldDate: soldDate,
            soldPrice: 2000.0
        )
        XCTAssertEqual(AssetCalculator.netCost(for: breakEvenItem), 0.0, accuracy: 0.01)
        XCTAssertEqual(AssetCalculator.dailyCost(for: breakEvenItem), 0.0, accuracy: 0.01)
        XCTAssertEqual(AssetCalculator.soldOutcome(for: breakEvenItem), .breakEven)
        XCTAssertTrue(AssetCalculator.soldOutcome(for: breakEvenItem).isBreakEven)
        XCTAssertEqual(AssetCalculator.recoveryRate(for: breakEvenItem)!, 1.0, accuracy: 0.001)
        
        // 场景 3: 正常折旧卖出 (售出价低于投入)
        let lossItem = AssetItem(
            name: "iPhone 12",
            price: 5000.0,
            purchaseDate: purchaseDate,
            status: .sold,
            soldDate: soldDate,
            soldPrice: 3000.0
        )
        XCTAssertEqual(AssetCalculator.netCost(for: lossItem), 2000.0, accuracy: 0.01)
        XCTAssertEqual(AssetCalculator.dailyCost(for: lossItem), 2000.0 / 30.0, accuracy: 0.01)
        XCTAssertEqual(AssetCalculator.soldOutcome(for: lossItem), .loss(netCost: 2000.0, lossAmount: 2000.0))
        XCTAssertEqual(AssetCalculator.recoveryRate(for: lossItem)!, 0.6, accuracy: 0.001)
        
        // 场景 4: 0元报废或赠送出清
        let scrapItem = AssetItem(
            name: "旧显示器",
            price: 800.0,
            purchaseDate: purchaseDate,
            status: .sold,
            soldDate: soldDate,
            soldPrice: 0.0
        )
        XCTAssertEqual(AssetCalculator.netCost(for: scrapItem), 800.0, accuracy: 0.01)
        XCTAssertEqual(AssetCalculator.soldOutcome(for: scrapItem), .zeroResale(grossCost: 800.0))
        XCTAssertEqual(AssetCalculator.recoveryRate(for: scrapItem)!, 0.0, accuracy: 0.001)
    }
    
    func testSoldAssetWithExpensesAndIncomes() {
        let purchaseDate = calendar.date(byAdding: .day, value: -20, to: Date())!
        let soldDate = Date()
        let asset = AssetItem(
            name: "Sony 相机",
            price: 10000.0,
            purchaseDate: purchaseDate,
            status: .sold,
            soldDate: soldDate,
            soldPrice: 11000.0,
            expenses: [FinancialRecord(title: "镜头", amount: 2000.0)],
            incomes: [FinancialRecord(title: "租赁回血", amount: 500.0)]
        )
        
        // gross = 10000 + 2000 - 500 = 11500.0
        XCTAssertEqual(AssetCalculator.grossCost(for: asset), 11500.0, accuracy: 0.01)
        // net = 11500 - 11000 = 500.0 (净折损 500 元)
        XCTAssertEqual(AssetCalculator.netCost(for: asset), 500.0, accuracy: 0.01)
        XCTAssertEqual(AssetCalculator.dailyCost(for: asset), 500.0 / 20.0, accuracy: 0.01)
        XCTAssertEqual(AssetCalculator.soldOutcome(for: asset), .loss(netCost: 500.0, lossAmount: 500.0))
    }
    
    func testOverviewStatsScopedForSoldTabAndAllTab() {
        // 构建完美匹配截图 27 与截图 1 的资产组合
        let activeAsset1 = AssetItem(name: "Mac", price: 50000.0, purchaseDate: calendar.date(byAdding: .day, value: -100, to: Date())!, status: .active)
        let activeAsset2 = AssetItem(name: "iPad", price: 32149.98, purchaseDate: calendar.date(byAdding: .day, value: -100, to: Date())!, status: .active)
        
        // MBP m5: 2000买，2000卖，持有时长 10 天 -> netCost = 0.0, daily = 0.0
        let soldAsset1 = AssetItem(
            name: "mbp m5",
            price: 2000.0,
            purchaseDate: calendar.date(byAdding: .day, value: -20, to: Date())!,
            status: .sold,
            soldDate: calendar.date(byAdding: .day, value: -10, to: Date())!,
            soldPrice: 2000.0
        )
        // MBP m2p: 1832买，2000卖，持有时长 28 天 -> netCost = -168.0, daily = -168 / 28 = -6.0
        let soldAsset2 = AssetItem(
            name: "MBP m2p",
            price: 1832.0,
            purchaseDate: calendar.date(byAdding: .day, value: -38, to: Date())!,
            status: .sold,
            soldDate: calendar.date(byAdding: .day, value: -10, to: Date())!,
            soldPrice: 2000.0
        )
        
        let allAssets = [activeAsset1, activeAsset2, soldAsset1, soldAsset2]
        
        // 1. 切换至「已卖出」Tab 视角 (还原截图 27)
        let soldOverview = AssetCalculator.calculateOverview(assets: allAssets, filterStatus: .sold)
        // 总资产应为已卖出净损益: 0 + (-168) = -168.00
        XCTAssertEqual(soldOverview.totalAssetValue, -168.00, accuracy: 0.01)
        // 日均应为已卖出合并日均: 0 + (-6.00) = -6.00
        XCTAssertEqual(soldOverview.totalDailyCost, -6.00, accuracy: 0.01)
        // 徽章显示 2/4
        XCTAssertEqual(soldOverview.displayCountBadge, "2/4")
        XCTAssertEqual(soldOverview.soldCount, 2)
        XCTAssertEqual(soldOverview.activeCount, 0)
        
        // 2. 切换至「全部」Tab 视角 (还原截图 1)
        let allOverview = AssetCalculator.calculateOverview(assets: allAssets, filterStatus: nil)
        // 总资产应为在役资产 (82149.98) + 已卖出净损益 (-168.00) = 81981.98
        XCTAssertEqual(allOverview.totalAssetValue, 81981.98, accuracy: 0.01)
        // 徽章显示 4/4
        XCTAssertEqual(allOverview.displayCountBadge, "4/4")
        XCTAssertEqual(allOverview.activeCount, 2)
        XCTAssertEqual(allOverview.soldCount, 2)
    }
}
