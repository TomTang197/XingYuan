import SwiftUI
import WidgetKit

struct XingYuanWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: XingYuanEntry
    
    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallWidgetView(data: entry.data, sortRule: entry.sortRule)
            case .systemMedium:
                MediumWidgetView(data: entry.data, sortRule: entry.sortRule)
            case .systemLarge:
                LargeWidgetView(data: entry.data, sortRule: entry.sortRule)
            default:
                SmallWidgetView(data: entry.data, sortRule: entry.sortRule)
            }
        }
        .containerBackground(for: .widget) {
            Color(nsColor: .windowBackgroundColor)
        }
    }
}

struct SmallWidgetView: View {
    let data: WidgetSnapshotData
    let sortRule: WidgetSortRule
    
    var body: some View {
        let topItem = data.sortedAssets(for: sortRule, limit: 1).first
        
        VStack(alignment: .leading, spacing: 6) {
            // Header
            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.46, green: 0.82, blue: 0.12))
                Text("星元")
                    .font(.system(size: 12, weight: .bold))
                Spacer()
                Text("\(data.activeCount) 件")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            Spacer(minLength: 2)
            
            // Core Metric
            VStack(alignment: .leading, spacing: 2) {
                Text("今日总日均")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                
                Text("¥\(String(format: "%.2f", data.totalDailyCost))")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.20, green: 0.70, blue: 0.10))
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 2)
            
            // Footer: Top 1 Highlight according to sort rule
            if let topItem = topItem {
                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 3) {
                        Text(sortRule.shortTitle)
                            .font(.system(size: 8.5, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("Top 1")
                            .font(.system(size: 8.5, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.20, green: 0.70, blue: 0.10))
                    }
                    HStack(spacing: 4) {
                        Text(topItem.name)
                            .font(.system(size: 9.5, weight: .medium))
                            .lineLimit(1)
                        Spacer()
                        if sortRule == .highestPrice || sortRule == .lowestPrice {
                            Text("¥\(Int(topItem.price))")
                                .font(.system(size: 9.5, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                        } else {
                            Text("¥\(String(format: "%.2f", topItem.dailyCost))/天")
                                .font(.system(size: 9.5, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0.20, green: 0.70, blue: 0.10))
                        }
                    }
                }
                .padding(.top, 2)
            } else {
                HStack {
                    Text("在役总额")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("¥\(Int(data.totalAssetValue))")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                }
                .padding(.top, 2)
            }
        }
        .padding(10)
    }
}

struct MediumWidgetView: View {
    let data: WidgetSnapshotData
    let sortRule: WidgetSortRule
    
    var body: some View {
        let items = data.sortedAssets(for: sortRule, limit: 5)
        
        HStack(spacing: 12) {
            // Left Column: Overview
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 0.46, green: 0.82, blue: 0.12))
                    Text("星元")
                        .font(.system(size: 12, weight: .bold))
                }
                
                Spacer(minLength: 0)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("今日在役总日均")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text("¥\(String(format: "%.2f", data.totalDailyCost))/天")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.20, green: 0.70, blue: 0.10))
                }
                
                Spacer(minLength: 0)
                
                HStack {
                    Text("在役 ¥\(Int(data.totalAssetValue))")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                    Text("·")
                        .foregroundColor(.secondary)
                    Text("\(data.activeCount) 件")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            // Right Column: Top 5 Assets according to Sort Rule
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(sortRule.topTitle)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.bottom, 1)
                
                if items.isEmpty {
                    Spacer()
                    Text("暂无在役资产")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        HStack(spacing: 5) {
                            Text("\(index + 1)")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundColor(index < 3 ? Color(red: 0.20, green: 0.70, blue: 0.10) : .secondary)
                                .frame(width: 8, alignment: .center)
                            
                            Image(systemName: item.iconName)
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                                .frame(width: 10)
                            
                            Text(item.name)
                                .font(.system(size: 9.5, weight: .medium))
                                .lineLimit(1)
                            
                            Spacer(minLength: 2)
                            
                            if sortRule == .highestPrice || sortRule == .lowestPrice {
                                Text("¥\(Int(item.price))")
                                    .font(.system(size: 9.5, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                            } else if sortRule == .newest {
                                Text("\(item.daysInService)天前")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.secondary)
                            } else if sortRule == .oldest {
                                Text("\(item.daysInService)天")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.secondary)
                            } else {
                                Text("¥\(String(format: "%.2f", item.dailyCost))/天")
                                    .font(.system(size: 9.5, weight: .semibold, design: .rounded))
                                    .foregroundColor(sortRule == .highestDaily ? Color.orange : Color(red: 0.20, green: 0.70, blue: 0.10))
                            }
                        }
                        .frame(height: 16)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
    }
}

struct LargeWidgetView: View {
    let data: WidgetSnapshotData
    let sortRule: WidgetSortRule
    
    var body: some View {
        let items = data.sortedAssets(for: sortRule, limit: 5)
        
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 0.46, green: 0.82, blue: 0.12))
                Text("星元")
                    .font(.system(size: 14, weight: .bold))
                Spacer()
                Text("服役中 \(data.activeCount) / \(data.totalCount) 件")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            // Dual Metric Cards
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("今日在役总日均")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text("¥\(String(format: "%.2f", data.totalDailyCost))/天")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.20, green: 0.70, blue: 0.10))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.primary.opacity(0.04)))
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("在役总资产")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Text("¥\(Int(data.totalAssetValue))")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.primary.opacity(0.04)))
            }
            
            Divider()
            
            // Ranking Section Header
            HStack {
                Text(sortRule.topTitle)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
                Text(sortRule.subtitle)
                    .font(.system(size: 9.5))
                    .foregroundColor(.secondary)
            }
            
            if items.isEmpty {
                Spacer()
                Text("暂无在役资产")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                VStack(spacing: 7) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        HStack(spacing: 8) {
                            Text("\(index + 1)")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(index < 3 ? Color(red: 0.20, green: 0.70, blue: 0.10) : .secondary)
                                .frame(width: 14, alignment: .center)
                            
                            Image(systemName: item.iconName)
                                .font(.system(size: 11))
                                .foregroundColor(.primary)
                                .frame(width: 22, height: 22)
                                .background(RoundedRectangle(cornerRadius: 5).fill(Color.primary.opacity(0.05)))
                            
                            VStack(alignment: .leading, spacing: 1) {
                                Text(item.name)
                                    .font(.system(size: 11.5, weight: .medium))
                                    .lineLimit(1)
                                Text("\(item.category) · 购入 \(item.daysInService) 天 · 原价 ¥\(Int(item.price))")
                                    .font(.system(size: 9.5))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 1) {
                                if sortRule == .highestPrice || sortRule == .lowestPrice {
                                    Text("¥\(Int(item.price))")
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Text("¥\(String(format: "%.2f", item.dailyCost))/天")
                                        .font(.system(size: 9.5))
                                        .foregroundColor(Color(red: 0.20, green: 0.70, blue: 0.10))
                                } else {
                                    Text("¥\(String(format: "%.2f", item.dailyCost))/天")
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundColor(sortRule == .highestDaily ? Color.orange : Color(red: 0.20, green: 0.70, blue: 0.10))
                                    Text("\(item.daysInService)天")
                                        .font(.system(size: 9.5))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(12)
    }
}
