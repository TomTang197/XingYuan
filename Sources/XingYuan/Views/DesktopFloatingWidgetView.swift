import SwiftUI
import SwiftData
import AppKit

public struct DesktopFloatingWidgetView: View {
    @Query private var assets: [AssetItem]
    @State private var isHovered: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        let stats = AssetCalculator.calculateOverview(assets: assets, filterStatus: .active)
        let activeAssets = assets
            .filter { $0.status == .active }
            .sorted { AssetCalculator.dailyCost(for: $0) < AssetCalculator.dailyCost(for: $1) }
        
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 0.46, green: 0.82, blue: 0.12))
                
                Text("星元 · 桌面小组件")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("服役中 \(stats.activeCount) 件")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                
                if isHovered {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity)
                }
            }
            
            Divider()
            
            // 核心指标
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("今日在役总日均")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text("¥\(String(format: "%.2f", stats.totalDailyCost))/天")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.20, green: 0.70, blue: 0.10))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("在役资产总值")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text("¥\(Int(stats.totalAssetValue))")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(0.6))
            )
            
            // 物超所值 Top 2
            VStack(alignment: .leading, spacing: 5) {
                Text("物尽其用 · 极致日均")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                
                if activeAssets.isEmpty {
                    Text("暂无在役资产")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(activeAssets.prefix(2)) { item in
                        let days = AssetCalculator.daysInService(for: item)
                        let daily = AssetCalculator.dailyCost(for: item)
                        HStack(spacing: 6) {
                            Image(systemName: item.iconName)
                                .font(.system(size: 12))
                                .foregroundColor(item.status.color)
                                .frame(width: 16)
                            
                            Text(item.name)
                                .font(.system(size: 11, weight: .medium))
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text("\(days)天")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                            
                            Text("¥\(String(format: "%.2f", daily))/天")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0.20, green: 0.70, blue: 0.10))
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .padding(14)
        .frame(width: 280)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 6)
        .onHover { isHovered = $0 }
    }
}
