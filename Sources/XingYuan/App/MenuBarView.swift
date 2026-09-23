import SwiftUI
import SwiftData

public struct MenuBarLabelView: View {
    @Query private var assets: [AssetItem]
    
    public init() {}
    
    public var body: some View {
        let stats = AssetCalculator.calculateOverview(assets: assets, filterStatus: .active)
        HStack(spacing: 4) {
            Image(systemName: "sparkles")
            Text("¥\(String(format: "%.2f", stats.totalDailyCost))/天")
                .font(.system(size: 12, weight: .medium, design: .rounded))
        }
    }
}

public struct MenuBarView: View {
    @Query private var assets: [AssetItem]
    @Environment(\.openWindow) private var openWindow
    @AppStorage("menuBarSortRule") private var sortRule: WidgetSortRule = .lowestDaily
    
    public init() {}
    
    public var body: some View {
        let stats = AssetCalculator.calculateOverview(assets: assets, filterStatus: .active)
        let activeAssets = assets.filter { $0.status == .active }
        
        let sortedAssets: [AssetItem] = {
            switch sortRule {
            case .lowestDaily:
                return activeAssets.sorted { AssetCalculator.dailyCost(for: $0) < AssetCalculator.dailyCost(for: $1) }
            case .highestDaily:
                return activeAssets.sorted { AssetCalculator.dailyCost(for: $0) > AssetCalculator.dailyCost(for: $1) }
            case .newest:
                return activeAssets.sorted { $0.purchaseDate > $1.purchaseDate }
            case .oldest:
                return activeAssets.sorted { $0.purchaseDate < $1.purchaseDate }
            case .highestPrice:
                return activeAssets.sorted { $0.price > $1.price }
            case .lowestPrice:
                return activeAssets.sorted { $0.price < $1.price }
            }
        }()
        
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(Color(red: 0.46, green: 0.82, blue: 0.12))
                Text("星元 (XingYuan)")
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
                    Text("今日在役总日均")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("¥\(String(format: "%.2f", stats.totalDailyCost))/天")
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
            
            // 排行榜区域：动态规则与选择器
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(sortRule.topTitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Picker("", selection: $sortRule) {
                        ForEach(WidgetSortRule.allCases, id: \.self) { rule in
                            Text(rule.shortTitle).tag(rule)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .scaleEffect(0.85)
                    .frame(width: 90)
                }
                
                if sortedAssets.isEmpty {
                    Text("暂无在役资产")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                } else {
                    ForEach(Array(sortedAssets.prefix(5).enumerated()), id: \.element.id) { index, item in
                        let days = AssetCalculator.daysInService(for: item)
                        let daily = AssetCalculator.dailyCost(for: item)
                        HStack(spacing: 8) {
                            Text("\(index + 1)")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(index < 3 ? Color(red: 0.20, green: 0.70, blue: 0.10) : .secondary)
                                .frame(width: 12, alignment: .center)
                            
                            Image(systemName: item.iconName)
                                .foregroundColor(item.status.color)
                                .frame(width: 16)
                            Text(item.name)
                                .font(.system(size: 12))
                                .lineLimit(1)
                            Spacer()
                            
                            if sortRule == .highestPrice || sortRule == .lowestPrice {
                                Text("¥\(Int(item.price))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("¥\(String(format: "%.2f", daily))/天")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(red: 0.20, green: 0.70, blue: 0.10))
                            } else if sortRule == .highestDaily {
                                Text("\(days)天")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("¥\(String(format: "%.2f", daily))/天")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color.orange)
                            } else {
                                Text("\(days)天")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("¥\(String(format: "%.2f", daily))/天")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(red: 0.20, green: 0.70, blue: 0.10))
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            
            Divider()
            
            // 底部操作
            HStack {
                Button("打开主窗口") {
                    openWindow(id: "main")
                    NSApplication.shared.activate(ignoringOtherApps: true)
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
        .frame(width: 310)
        .onChange(of: sortRule) { _, newRule in
            WidgetDataSharing.syncSnapshot(from: assets, defaultSortRule: newRule)
        }
    }
}
