import SwiftUI

public struct AssetTableView: View {
    public let assets: [AssetItem]
    @Binding public var selectedAsset: AssetItem?
    public var onEdit: (AssetItem) -> Void
    public var onMarkAsSold: (AssetItem) -> Void
    public var onMarkAsRetired: (AssetItem) -> Void
    public var onDelete: (AssetItem) -> Void
    
    @State private var selectedID: UUID?
    @State private var sortOrder = [KeyPathComparator(\AssetItem.purchaseDate, order: .reverse)]
    
    public init(
        assets: [AssetItem],
        selectedAsset: Binding<AssetItem?>,
        onEdit: @escaping (AssetItem) -> Void,
        onMarkAsSold: @escaping (AssetItem) -> Void,
        onMarkAsRetired: @escaping (AssetItem) -> Void,
        onDelete: @escaping (AssetItem) -> Void
    ) {
        self.assets = assets
        self._selectedAsset = selectedAsset
        self.onEdit = onEdit
        self.onMarkAsSold = onMarkAsSold
        self.onMarkAsRetired = onMarkAsRetired
        self.onDelete = onDelete
    }
    
    public var body: some View {
        Table(assets, selection: $selectedID) {
            TableColumn("名称") { asset in
                HStack(spacing: 8) {
                    Image(systemName: asset.iconName)
                        .font(.system(size: 14))
                        .foregroundColor(asset.status.color)
                        .frame(width: 20)
                    
                    Text(asset.name)
                        .font(.system(size: 13, weight: .medium))
                    
                    if asset.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.orange)
                    }
                }
            }
            .width(min: 140, ideal: 180)
            
            TableColumn("状态") { asset in
                StatusBadge(asset.status)
            }
            .width(min: 75, ideal: 85)
            
            TableColumn("原价 / 二手卖出价") { asset in
                if asset.status == .sold {
                    if let soldPrice = asset.soldPrice {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("买入 ¥\(Int(asset.price))")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
                            Text("卖出 ¥\(Int(soldPrice))")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.orange)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("买入 ¥\(Int(asset.price))")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
                            Text("待录入卖出价")
                                .font(.system(size: 10))
                                .foregroundColor(.orange)
                        }
                    }
                } else {
                    Text("¥\(String(format: "%.2f", asset.price))")
                        .font(.system(size: 12, design: .monospaced))
                }
            }
            .width(min: 110, ideal: 125)
            
            TableColumn("服役天数") { asset in
                let days = AssetCalculator.daysInService(for: asset)
                Text("\(days) 天")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .width(min: 70, ideal: 85)
            
            TableColumn("日均成本") { asset in
                let daily = AssetCalculator.dailyCost(for: asset)
                HStack(spacing: 2) {
                    Text("¥\(String(format: "%.2f", daily))")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(daily < 0 ? Color(red: 0.46, green: 0.82, blue: 0.12) : (asset.status == .sold ? Color(red: 0.90, green: 0.60, blue: 0.15) : (asset.status == .retired ? .secondary : Color(red: 0.46, green: 0.82, blue: 0.12))))
                    Text(asset.rule == .byCount ? "/次" : "/天")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            .width(min: 100, ideal: 120)
            
            TableColumn("类别") { asset in
                Text(asset.category)
                    .font(.system(size: 11))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(nsColor: .quaternaryLabelColor).opacity(0.5))
                    )
            }
            .width(min: 60, ideal: 80)
            
            TableColumn("目标价 / 盈亏") { asset in
                if asset.status == .sold {
                    switch AssetCalculator.soldOutcome(for: asset) {
                    case .profit(let amt):
                        Text("理财净赚 ¥\(String(format: "%.1f", amt))")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(red: 0.46, green: 0.82, blue: 0.12))
                    case .breakEven:
                        Text("平价全额回血")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.blue)
                    case .loss(let netCost, _):
                        Text("最终净损 ¥\(String(format: "%.1f", netCost))")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    case .zeroResale:
                        Text("0元残值报废")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    case .unrecorded:
                        Text("-")
                            .foregroundColor(.secondary)
                    }
                } else if let target = asset.targetDailyCost {
                    let daily = AssetCalculator.dailyCost(for: asset)
                    let remaining = AssetCalculator.targetDaysRemaining(for: asset)
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 3) {
                            Text("目标")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                            Text("¥\(String(format: "%.2f", target))\(asset.rule.unitString)")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(daily <= target ? Color(red: 0.46, green: 0.82, blue: 0.12) : .orange)
                        }
                        
                        if let rem = remaining {
                            if rem > 0 {
                                Text("还剩 \(rem) \(asset.rule.unitName)")
                                    .font(.system(size: 10))
                                    .foregroundColor(.orange)
                            } else {
                                Text("已回本")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(Color(red: 0.46, green: 0.82, blue: 0.12))
                            }
                        }
                    }
                } else {
                    Text("-")
                        .foregroundColor(.secondary)
                }
            }
            .width(min: 110, ideal: 130)
        }
        .onChange(of: selectedID) { _, newID in
            if let id = newID {
                selectedAsset = assets.first(where: { $0.id == id })
            } else {
                selectedAsset = nil
            }
        }
        .onChange(of: selectedAsset) { _, newAsset in
            if selectedID != newAsset?.id {
                selectedID = newAsset?.id
            }
        }
        .onAppear {
            if selectedID != selectedAsset?.id {
                selectedID = selectedAsset?.id
            }
        }
    }
}
