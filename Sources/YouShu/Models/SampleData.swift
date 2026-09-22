import Foundation
import SwiftData

public enum SampleData {
    public static func loadSampleDataIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<AssetItem>()
        if let existing = try? context.fetch(descriptor), !existing.isEmpty {
            var changed = false
            for item in existing {
                if item.name == "MBP m2p" && (item.soldPrice == nil || item.soldPrice == 0.0) {
                    item.soldPrice = 2000.00
                    changed = true
                }
                if item.name == "mbp m5" && (item.soldPrice == nil || item.soldPrice == 0.0) {
                    item.soldPrice = 2000.00
                    changed = true
                }
            }
            if changed {
                try? context.save()
            }
            return
        }
        
        loadSampleData(context: context)
    }
    
    public static func loadSampleData(context: ModelContext) {
        let cal = Calendar.current
        let today = Date()
        
        let samples: [(name: String, price: Double, daysAgo: Int, status: AssetStatus, soldPrice: Double?, soldDaysAgo: Int?, targetDaily: Double?, cat: String, icon: String)] = [
            ("爱否 F1", 168.99, 2682, .active, nil, nil, 0.05, "居家", "cube.box.fill"),
            ("Hagis 380w", 350.00, 84, .active, nil, nil, 2.0, "数码", "powerplug.fill"),
            ("iPad pro m1", 8548.00, 1473, .active, nil, nil, 5.0, "数码", "ipad"),
            ("Fiat 2015", 34000.00, 1243, .active, nil, nil, 20.0, "出行", "car.fill"),
            ("MBP m4m", 24000.00, 38, .active, nil, nil, 30.0, "办公", "laptopcomputer"),
            ("mbp m5", 2000.00, 252, .sold, 2000.00, 10, nil, "办公", "laptopcomputer"),
            ("MBP m2p", 1832.00, 931, .sold, 2000.00, 903, nil, "办公", "laptopcomputer"),
            ("AirPods pro 2", 1724.00, 1783, .active, nil, nil, 1.0, "影音", "airpodspro"),
            ("AirPods pro 3", 1560.00, 175, .active, nil, nil, 8.0, "影音", "airpodspro"),
            ("iPhone 13 Pro Max 256G", 11799.00, 1796, .active, nil, nil, 6.0, "数码", "iphone")
        ]
        
        for item in samples {
            let purchaseDate = cal.date(byAdding: .day, value: -item.daysAgo, to: today) ?? today
            let soldDate = item.soldDaysAgo.flatMap { cal.date(byAdding: .day, value: -$0, to: today) }
            
            let asset = AssetItem(
                name: item.name,
                price: item.price,
                purchaseDate: purchaseDate,
                category: item.cat,
                tags: [item.cat],
                iconName: item.icon,
                status: item.status,
                targetDailyCost: item.targetDaily,
                soldDate: soldDate,
                soldPrice: item.soldPrice
            )
            context.insert(asset)
        }
        
        // 载入几个心愿单示例
        let wish1 = WishItem(
            name: "Sony A7M5 相机",
            estimatedPrice: 17999.0,
            category: "数码",
            tags: ["摄影", "心愿"],
            iconName: "camera.fill",
            targetDailyCost: 20.0,
            notes: "等降价到 1.6w 入手"
        )
        let wish2 = WishItem(
            name: "Herman Miller 人体工学椅",
            estimatedPrice: 10800.0,
            category: "办公",
            tags: ["健康", "久坐"],
            iconName: "chair.lounge.fill",
            targetDailyCost: 5.0,
            notes: "保护腰椎，预计使用 6 年"
        )
        context.insert(wish1)
        context.insert(wish2)
        
        try? context.save()
    }
}
