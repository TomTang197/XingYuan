import SwiftUI
import SwiftData

public struct MenuBarView: View {
    @Query private var assets: [AssetItem]
    @Environment(\.openWindow) private var openWindow
    
    public init() {}
    
    public var body: some View {
        let stats = AssetCalculator.calculateOverview(assets: assets)
        let activeAssets = assets
            .filter { $0.status == .active }
            .sorted { AssetCalculator.dailyCost(for: $0) < AssetCalculator.dailyCost(for: $1) }
        
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Image(systemName: "bolt.circle.fill")
                    .foregroundColor(Color(red: 0.46, green: 0.82, blue: 0.12))
                Text("有数 (YouShu)")
                    .font(.headline)
                Spacer()
                Text("服役中 \(stats.activeCount) 件")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // 核心统计两列
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("今日总日均")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("¥\(String(format: "%.2f", stats.totalDailyCost))")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.20, green: 0.70, blue: 0.10))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("在役总资产")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("¥\(String(format: "%.2f", stats.totalAssetValue))")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(nsColor: .controlBackgroundColor)))
            
            // 物尽其用 Top 3 (日均摊薄最极致的物品)
            VStack(alignment: .leading, spacing: 6) {
                Text("物超所值 Top 3")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ForEach(activeAssets.prefix(3)) { item in
                    let days = AssetCalculator.daysInService(for: item)
                    let daily = AssetCalculator.dailyCost(for: item)
                    HStack(spacing: 8) {
                        Image(systemName: item.iconName)
                            .foregroundColor(item.status.color)
                            .frame(width: 16)
                        Text(item.name)
                            .font(.system(size: 12))
                            .lineLimit(1)
                        Spacer()
                        Text("\(days)天")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("¥\(String(format: "%.2f", daily))/天")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.20, green: 0.70, blue: 0.10))
                    }
                    .padding(.vertical, 2)
                }
            }
            
            Divider()
            
            // 底部操作
            HStack {
                Button("打开主窗口") {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                    if let window = NSApplication.shared.windows.first {
                        window.makeKeyAndOrderFront(nil)
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
                
                Button("退出") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(width: 280)
    }
}
