import SwiftUI

public struct OverviewCardView: View {
    public let stats: OverviewStats
    
    public init(stats: OverviewStats) {
        self.stats = stats
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header: 资产总览 与 总数徽标
            HStack {
                Text("资产总览")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(stats.displayCountBadge)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color(nsColor: .quaternaryLabelColor).opacity(0.5))
                    )
                
                Spacer()
            }
            
            // 数据双列：总资产 & 日均成本
            HStack(spacing: 32) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("总资产")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text("¥\(String(format: "%.2f", stats.totalAssetValue))")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("日均成本")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text("¥\(String(format: "%.2f", stats.totalDailyCost))")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.46, green: 0.82, blue: 0.12))
                }
                
                Spacer()
            }
            
            // 状态统计与进度条
            VStack(spacing: 8) {
                HStack {
                    statusCountLabel(title: "服役中", count: stats.activeCount, color: AssetStatus.active.color)
                    Spacer()
                    statusCountLabel(title: "已退役", count: stats.retiredCount, color: AssetStatus.retired.color)
                    Spacer()
                    statusCountLabel(title: "已卖出", count: stats.soldCount, color: AssetStatus.sold.color)
                }
                
                // 状态彩色占比条 (精确扣减 spacing 防止溢出)
                GeometryReader { geo in
                    let visibleSegments = (stats.activeCount > 0 ? 1 : 0) + (stats.retiredCount > 0 ? 1 : 0) + (stats.soldCount > 0 ? 1 : 0)
                    let totalSpacing = CGFloat(max(0, visibleSegments - 1)) * 3.0
                    let availableWidth = max(0, geo.size.width - totalSpacing)
                    let total = max(1, stats.totalCount)
                    
                    let activeWidth = availableWidth * CGFloat(stats.activeCount) / CGFloat(total)
                    let retiredWidth = availableWidth * CGFloat(stats.retiredCount) / CGFloat(total)
                    let soldWidth = availableWidth * CGFloat(stats.soldCount) / CGFloat(total)
                    
                    HStack(spacing: 3) {
                        if stats.activeCount > 0 {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(AssetStatus.active.color)
                                .frame(width: activeWidth)
                        }
                        if stats.retiredCount > 0 {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(AssetStatus.retired.color)
                                .frame(width: retiredWidth)
                        }
                        if stats.soldCount > 0 {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(AssetStatus.sold.color)
                                .frame(width: soldWidth)
                        }
                        if stats.totalCount == 0 {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(nsColor: .quaternaryLabelColor))
                        }
                    }
                }
                .frame(height: 5)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(nsColor: .separatorColor).opacity(0.4), lineWidth: 1)
        )
    }
    
    private func statusCountLabel(title: String, count: Int, color: Color) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            
            Text("\(count)")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
        }
    }
}
