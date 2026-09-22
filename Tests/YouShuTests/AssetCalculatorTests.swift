import XCTest
@testable import YouShu

final class AssetCalculatorTests: XCTestCase {
    func testActiveAssetDailyCost() {
        let calendar = Calendar.current
        let purchaseDate = calendar.date(byAdding: .day, value: -100, to: Date())!
        
        let asset = AssetItem(
            name: "Test Mac",
            price: 10000.0,
            purchaseDate: purchaseDate,
            status: .active
        )
        
        let days = AssetCalculator.daysInService(for: asset)
        XCTAssertEqual(days, 100)
        
        let daily = AssetCalculator.dailyCost(for: asset)
        XCTAssertEqual(daily, 100.0, accuracy: 0.1)
    }
    
    func testSoldAssetWithResidualValue() {
        let calendar = Calendar.current
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
        
        let days = AssetCalculator.daysInService(for: asset)
        XCTAssertEqual(days, 100)
        
        // Net cost = 6000 - 3000 = 3000. Days = 100 -> Daily = 30
        let daily = AssetCalculator.dailyCost(for: asset)
        XCTAssertEqual(daily, 30.0, accuracy: 0.1)
    }
    
    func testTargetDaysCountdown() {
        let calendar = Calendar.current
        let purchaseDate = calendar.date(byAdding: .day, value: -30, to: Date())!
        
        let asset = AssetItem(
            name: "Headphones",
            price: 1000.0,
            purchaseDate: purchaseDate,
            status: .active,
            targetDailyCost: 10.0 // Needs 1000 / 10 = 100 days
        )
        
        let remaining = AssetCalculator.targetDaysRemaining(for: asset)
        // 100 - 30 = 70 days left
        XCTAssertEqual(remaining, 70)
        XCTAssertFalse(AssetCalculator.isTargetAchieved(for: asset))
    }
}
