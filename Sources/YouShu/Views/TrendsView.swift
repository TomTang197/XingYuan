import SwiftUI
import Charts
import SwiftData

public struct TrendsView: View {
    @Query private var assets: [AssetItem]
    @State private var selectedRange: String = "全部"
    private let ranges = ["全部", "本月", "近7天", "近30天", "近90天", "近180天"]
    
    public init() {}
    
    public var body: some View {
        let stats = AssetCalculator.calculateOverview(assets: assets)
        let distribution = AssetCalculator.calculateDistribution(assets: assets)
        let monthly = AssetCalculator.calculateMonthlyPurchases(assets: assets)
        let totalPurchased = assets.reduce(0.0) { $0 + $1.price }
        let avgMonthly = monthly.isEmpty ? 0 : totalPurchased / Double(monthly.count)
        
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header and Range Filter
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("趋势 洞悉")
                            .font(.system(size: 22, weight: .bold))
                        Text("追踪个人资产配置演进与长期日均成本摊薄")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Picker("", selection: $selectedRange) {
                        ForEach(ranges, id: \.self) { r in
                            Text(r).tag(r)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 320)
                }
                
                // Chart Card 1: 资产总值与状态分布
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("资产总值")
                                .font(.system(size: 15, weight: .semibold))
                            Text("总价值: ¥\(String(format: "%.2f", stats.totalAssetValue))    数量: \(stats.totalCount)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    
                    // Swift Charts: 资产规模历史演化柱图
                    Chart {
                        ForEach(monthly) { m in
                            BarMark(
                                x: .value("月份", m.monthKey),
                                y: .value("金额", m.totalAmount)
                            )
                            .foregroundStyle(Color(red: 0.46, green: 0.82, blue: 0.12))
                            .cornerRadius(4)
                        }
                    }
                    .frame(height: 160)
                    .chartYAxis {
                        AxisMarks(values: .automatic(desiredCount: 4)) { val in
                            AxisValueLabel {
                                if let v = val.as(Double.self) {
                                    Text("¥\(Int(v / 10000))w")
                                        .font(.system(size: 10))
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // 状态分布明细表 (还原原图21)
                    VStack(spacing: 8) {
                        HStack {
                            Text("资产状态")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 100, alignment: .leading)
                            Text("占比")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 80, alignment: .trailing)
                            Spacer()
                            Text("金额")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 110, alignment: .trailing)
                            Text("数量")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 60, alignment: .trailing)
                        }
                        
                        ForEach(distribution) { item in
                            HStack {
                                HStack(spacing: 6) {
                                    Circle().fill(item.status.color).frame(width: 6, height: 6)
                                    Text(item.status.title)
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .frame(width: 100, alignment: .leading)
                                
                                Text(String(format: "%.1f%%", item.percentage * 100))
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .frame(width: 80, alignment: .trailing)
                                
                                Spacer()
                                
                                Text("¥\(String(format: "%.2f", item.amount))")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .frame(width: 110, alignment: .trailing)
                                
                                Text("\(item.count)")
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .frame(width: 60, alignment: .trailing)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                )
                
                // Chart Card 2: 新增资产 (还原原图22)
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("新增资产")
                                .font(.system(size: 15, weight: .semibold))
                            Text("购入总额: ¥\(String(format: "%.2f", totalPurchased))")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                        Spacer()
                    }
                    
                    Chart {
                        ForEach(monthly) { m in
                            BarMark(
                                x: .value("日期", m.monthKey),
                                y: .value("金额", m.totalAmount)
                            )
                            .foregroundStyle(Color(red: 0.46, green: 0.82, blue: 0.12))
                            .cornerRadius(4)
                        }
                        
                        RuleMark(y: .value("平均", avgMonthly))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                            .foregroundStyle(Color.green.opacity(0.6))
                            .annotation(position: .top, alignment: .trailing) {
                                Text("平均 ¥\(Int(avgMonthly / 10000))w")
                                    .font(.system(size: 9))
                                    .foregroundColor(.green)
                            }
                    }
                    .frame(height: 150)
                    .chartYAxis {
                        AxisMarks(values: .automatic(desiredCount: 3)) { val in
                            AxisValueLabel {
                                if let v = val.as(Double.self) {
                                    Text("¥\(Int(v / 10000))w")
                                        .font(.system(size: 10))
                                }
                            }
                        }
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                )
                
                // Chart Card 3: 日均成本动态曲线 (还原原图22)
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("总日均成本走势")
                                .font(.system(size: 15, weight: .semibold))
                            Text("当前全局日均: ¥\(String(format: "%.2f", stats.totalDailyCost))/天")
                                .font(.caption)
                                .foregroundColor(Color(red: 0.20, green: 0.70, blue: 0.10))
                        }
                        Spacer()
                    }
                    
                    // 生成日均成本随时间摊薄的曲线
                    let dailyTrend = generateDailyTrendData()
                    
                    Chart {
                        ForEach(dailyTrend, id: \.date) { pt in
                            LineMark(
                                x: .value("日期", pt.dateStr),
                                y: .value("日均成本", pt.dailyCost)
                            )
                            .interpolationMethod(.monotone)
                            .foregroundStyle(Color(red: 0.46, green: 0.82, blue: 0.12))
                            
                            AreaMark(
                                x: .value("日期", pt.dateStr),
                                y: .value("日均成本", pt.dailyCost)
                            )
                            .interpolationMethod(.monotone)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 0.46, green: 0.82, blue: 0.12).opacity(0.25), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                    }
                    .frame(height: 150)
                    .chartYAxis {
                        AxisMarks(values: .automatic(desiredCount: 4)) { val in
                            AxisValueLabel {
                                if let v = val.as(Double.self) {
                                    Text("¥\(Int(v))").font(.system(size: 10))
                                }
                            }
                        }
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                )
            }
            .padding(24)
        }
    }
    
    private struct DailyTrendPoint {
        var date: Date
        var dateStr: String
        var dailyCost: Double
    }
    
    private func generateDailyTrendData() -> [DailyTrendPoint] {
        guard !assets.isEmpty else { return [] }
        let cal = Calendar.current
        let today = Date()
        let sorted = assets.sorted { $0.purchaseDate < $1.purchaseDate }
        guard let earliest = sorted.first?.purchaseDate else { return [] }
        
        let totalDays = max(1, cal.dateComponents([.day], from: earliest, to: today).day ?? 1)
        let sampleCount = min(25, max(5, totalDays))
        let step = max(1, totalDays / sampleCount)
        
        let df = DateFormatter()
        df.dateFormat = "M.d"
        
        var points: [DailyTrendPoint] = []
        for d in stride(from: 1, through: totalDays, by: step) {
            let pointDate = cal.date(byAdding: .day, value: d, to: earliest) ?? today
            let activeAtDate = assets.filter { $0.purchaseDate <= pointDate && ($0.status == .active || ($0.soldDate ?? today) >= pointDate) }
            let sumDaily = activeAtDate.reduce(0.0) { sum, item in
                let days = max(1, cal.dateComponents([.day], from: item.purchaseDate, to: pointDate).day ?? 1)
                return sum + (item.price / Double(days))
            }
            points.append(DailyTrendPoint(date: pointDate, dateStr: df.string(from: pointDate), dailyCost: sumDaily))
        }
        
        return points
    }
}
