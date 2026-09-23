import XCTest
@testable import XingYuan

final class WidgetSortingTests: XCTestCase {
    func testAllSixWidgetSortRules() {
        let now = Date()
        let cal = Calendar.current
        
        let item1 = WidgetAssetItem(
            name: "A_便宜且久",
            iconName: "cube",
            daysInService: 1000,
            dailyCost: 0.1,
            price: 100,
            purchaseDate: cal.date(byAdding: .day, value: -1000, to: now)!,
            category: "测试"
        )
        
        let item2 = WidgetAssetItem(
            name: "B_贵且新",
            iconName: "cube",
            daysInService: 10,
            dailyCost: 100.0,
            price: 10000,
            purchaseDate: cal.date(byAdding: .day, value: -10, to: now)!,
            category: "测试"
        )
        
        let item3 = WidgetAssetItem(
            name: "C_中间档",
            iconName: "cube",
            daysInService: 100,
            dailyCost: 10.0,
            price: 1000,
            purchaseDate: cal.date(byAdding: .day, value: -100, to: now)!,
            category: "测试"
        )
        
        let data = WidgetSnapshotData(
            totalDailyCost: 110.1,
            totalAssetValue: 11100,
            activeCount: 3,
            totalCount: 3,
            allActiveAssets: [item1, item2, item3]
        )
        
        // 1. 最低每日 (Lowest Daily)
        let lowestDaily = data.sortedAssets(for: .lowestDaily, limit: 3)
        XCTAssertEqual(lowestDaily.map(\.name), ["A_便宜且久", "C_中间档", "B_贵且新"])
        
        // 2. 最高每日 (Highest Daily)
        let highestDaily = data.sortedAssets(for: .highestDaily, limit: 3)
        XCTAssertEqual(highestDaily.map(\.name), ["B_贵且新", "C_中间档", "A_便宜且久"])
        
        // 3. 最新购买 (Newest)
        let newest = data.sortedAssets(for: .newest, limit: 3)
        XCTAssertEqual(newest.map(\.name), ["B_贵且新", "C_中间档", "A_便宜且久"])
        
        // 4. 最旧服役 (Oldest)
        let oldest = data.sortedAssets(for: .oldest, limit: 3)
        XCTAssertEqual(oldest.map(\.name), ["A_便宜且久", "C_中间档", "B_贵且新"])
        
        // 5. 最高原价 (Highest Price)
        let highestPrice = data.sortedAssets(for: .highestPrice, limit: 3)
        XCTAssertEqual(highestPrice.map(\.name), ["B_贵且新", "C_中间档", "A_便宜且久"])
        
        // 6. 最低原价 (Lowest Price)
        let lowestPrice = data.sortedAssets(for: .lowestPrice, limit: 3)
        XCTAssertEqual(lowestPrice.map(\.name), ["A_便宜且久", "C_中间档", "B_贵且新"])
    }
}
