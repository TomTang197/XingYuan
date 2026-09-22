import SwiftUI

public struct AssetCardItemView: View {
    public let asset: AssetItem
    public let isSelected: Bool
    public var onSelect: () -> Void
    public var onMarkAsSold: () -> Void
    public var onMarkAsRetired: () -> Void
    public var onEdit: () -> Void
    public var onDelete: () -> Void
    
    @State private var isHovered: Bool = false
    
    public init(
        asset: AssetItem,
        isSelected: Bool = false,
        onSelect: @escaping () -> Void = {},
        onMarkAsSold: @escaping () -> Void = {},
        onMarkAsRetired: @escaping () -> Void = {},
        onEdit: @escaping () -> Void = {},
        onDelete: @escaping () -> Void = {}
    ) {
        self.asset = asset
        self.isSelected = isSelected
        self.onSelect = onSelect
        self.onMarkAsSold = onMarkAsSold
        self.onMarkAsRetired = onMarkAsRetired
        self.onEdit = onEdit
        self.onDelete = onDelete
    }
    
    public var body: some View {
        let days = AssetCalculator.daysInService(for: asset)
        let daily = AssetCalculator.dailyCost(for: asset)
        let remainingDays = AssetCalculator.targetDaysRemaining(for: asset)
        
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                // Top row: Icon on left, Status badge & Pin on right
                HStack(alignment: .top) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(nsColor: .quaternaryLabelColor).opacity(0.35))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color(nsColor: .separatorColor).opacity(0.3), lineWidth: 1)
                            )
                        
                        Image(systemName: asset.iconName)
                            .font(.system(size: 24))
                            .foregroundColor(asset.status.color)
                    }
                    .frame(width: 48, height: 48)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        StatusBadge(asset.status)
                        
                        if asset.isPinned {
                            Image(systemName: "pin.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                // Title and price | days (若已卖出则显示买入价与卖出价对照)
                VStack(alignment: .leading, spacing: 3) {
                    Text(asset.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 5) {
                        if asset.status == .sold {
                            if let soldPrice = asset.soldPrice {
                                Text("买 ¥\(Int(asset.price)) ➔ 卖 ¥\(Int(soldPrice))")
                                    .foregroundColor(Color.orange)
                            } else {
                                Text("买 ¥\(Int(asset.price)) ➔ 卖出待录入")
                                    .foregroundColor(Color.orange)
                            }
                            Text("|")
                                .foregroundColor(Color(nsColor: .separatorColor))
                            Text("\(days)\(asset.rule.unitName)")
                        } else {
                            Text("¥\(String(format: "%.2f", asset.price))")
                            Text("|")
                                .foregroundColor(Color(nsColor: .separatorColor))
                            Text("\(days)\(asset.rule.unitName)")
                        }
                    }
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 4)
                
                // Bottom row: Daily Cost & Target Price & Countdown (with fixed height to prevent baseline jitter)
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("¥\(String(format: "%.2f", daily))")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(daily < 0 ? Color(red: 0.46, green: 0.82, blue: 0.12) : (asset.status == .sold ? Color(red: 0.90, green: 0.60, blue: 0.15) : (asset.status == .retired ? .secondary : Color(red: 0.46, green: 0.82, blue: 0.12))))
                            
                            Text(asset.rule.unitString)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        if asset.status == .sold {
                            // 卖出场景下的盈亏标签
                            switch AssetCalculator.soldOutcome(for: asset) {
                            case .profit(let amt):
                                Text("理财净赚 ¥\(String(format: "%.1f", amt))")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(Color(red: 0.46, green: 0.82, blue: 0.12))
                            case .breakEven:
                                Text("平价全额回血")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(.blue)
                            case .loss(let netCost, _):
                                Text("最终净损 ¥\(String(format: "%.1f", netCost))")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.secondary)
                            case .zeroResale:
                                Text("0元残值出清")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.secondary)
                            case .unrecorded:
                                Color.clear.frame(height: 14)
                            }
                        } else if let target = asset.targetDailyCost {
                            HStack(spacing: 3) {
                                Text("目标")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.secondary)
                                Text("¥\(String(format: "%.2f", target))\(asset.rule.unitString)")
                                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                                    .foregroundColor(daily <= target ? Color(red: 0.46, green: 0.82, blue: 0.12) : .orange)
                            }
                        } else {
                            // 预留微型占位符保持多张卡片并排时大号数字基线绝对对齐
                            Color.clear.frame(height: 14)
                        }
                    }
                    .frame(minHeight: 38, alignment: .bottomLeading)
                    
                    Spacer(minLength: 4)
                    
                    if let remaining = remainingDays {
                        if remaining > 0 {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("还剩 \(remaining)\(asset.rule.unitName)")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule()
                                            .fill(Color.orange.opacity(0.12))
                                    )
                                    .minimumScaleFactor(0.8)
                                    .lineLimit(1)
                            }
                        } else {
                            Text("已回本")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color(red: 0.46, green: 0.82, blue: 0.12))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(Color(red: 0.46, green: 0.82, blue: 0.12).opacity(0.12))
                                )
                                .lineLimit(1)
                        }
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color.accentColor.opacity(0.08) : (isHovered ? Color(nsColor: .controlBackgroundColor).opacity(0.9) : Color(nsColor: .controlBackgroundColor)))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.accentColor : (isHovered ? Color(nsColor: .separatorColor) : Color(nsColor: .separatorColor).opacity(0.4)), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: Color.black.opacity(isHovered ? 0.08 : 0.02), radius: isHovered ? 8 : 4, x: 0, y: isHovered ? 4 : 1)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .contextMenu {
            Button("编辑详情") { onEdit() }
            
            Divider()
            
            if asset.status == .active {
                Button("标记为已卖出...") { onMarkAsSold() }
                Button("标记为已退役") { onMarkAsRetired() }
            } else {
                Button("恢复为服役中") {
                    asset.status = .active
                    asset.retiredDate = nil
                    asset.soldDate = nil
                }
            }
            
            Button(asset.isPinned ? "取消置顶" : "置顶") {
                asset.isPinned.toggle()
            }
            
            Divider()
            
            Button("删除", role: .destructive) { onDelete() }
        }
    }
}
