import SwiftUI
import WidgetKit

struct XingYuanWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: XingYuanEntry
    
    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallWidgetView(data: entry.data)
            case .systemMedium:
                MediumWidgetView(data: entry.data)
            case .systemLarge:
                LargeWidgetView(data: entry.data)
            default:
                SmallWidgetView(data: entry.data)
            }
        }
        .containerBackground(for: .widget) {
            Color(nsColor: .windowBackgroundColor)
        }
    }
}

struct SmallWidgetView: View {
    let data: WidgetSnapshotData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header
            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.46, green: 0.82, blue: 0.12))
                Text("星元")
                    .font(.system(size: 12, weight: .bold))
                Spacer()
                Text("\(data.activeCount) 件在役")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            Spacer(minLength: 2)
            
            // Core Metric
            VStack(alignment: .leading, spacing: 2) {
                Text("今日总日均")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                
                Text("¥\(String(format: "%.2f", data.totalDailyCost))")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.20, green: 0.70, blue: 0.10))
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 2)
            
            // Footer
            HStack {
                Text("在役资产")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                Spacer()
                Text("¥\(Int(data.totalAssetValue))")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .padding(.top, 2)
        }
        .padding(10)
    }
}

struct MediumWidgetView: View {
    let data: WidgetSnapshotData
    
    var body: some View {
        HStack(spacing: 12) {
            // Left Column: Overview
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 0.46, green: 0.82, blue: 0.12))
                    Text("星元追踪")
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
            
            // Right Column: Top 5 Assets
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text("物超所值 Top 5")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.bottom, 1)
                
                if data.topAssets.isEmpty {
                    Spacer()
                    Text("暂无在役资产")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    ForEach(Array(data.topAssets.prefix(5).enumerated()), id: \.element.id) { index, item in
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
                            
                            Text("¥\(String(format: "%.2f", item.dailyCost))/天")
                                .font(.system(size: 9.5, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0.20, green: 0.70, blue: 0.10))
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
    
    var body: some View {
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
                Text("物超所值 Top 5 (日均最低资产)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
                Text("日均成本")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            if data.topAssets.isEmpty {
                Spacer()
                Text("暂无在役资产")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                VStack(spacing: 7) {
                    ForEach(Array(data.topAssets.prefix(5).enumerated()), id: \.element.id) { index, item in
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
                                Text("\(item.category) · 服役 \(item.daysInService) 天")
                                    .font(.system(size: 9.5))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("¥\(String(format: "%.2f", item.dailyCost))/天")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.20, green: 0.70, blue: 0.10))
                        }
                    }
                }
            }
        }
        .padding(12)
    }
}
