import SwiftUI
import Charts

public struct AssetInspectorView: View {
    @Bindable public var asset: AssetItem
    public var onClose: () -> Void
    public var onEdit: () -> Void
    public var onMarkAsSold: () -> Void
    
    @State private var newExpenseTitle: String = ""
    @State private var newExpenseAmount: String = ""
    @State private var showAddExpense: Bool = false
    
    public init(
        asset: AssetItem,
        onClose: @escaping () -> Void = {},
        onEdit: @escaping () -> Void = {},
        onMarkAsSold: @escaping () -> Void = {}
    ) {
        self.asset = asset
        self.onClose = onClose
        self.onEdit = onEdit
        self.onMarkAsSold = onMarkAsSold
    }
    
    public var body: some View {
        let days = AssetCalculator.daysInService(for: asset)
        let net = AssetCalculator.netCost(for: asset)
        let daily = AssetCalculator.dailyCost(for: asset)
        let remaining = AssetCalculator.targetDaysRemaining(for: asset)
        let curvePoints = AssetCalculator.costDecayCurve(for: asset)
        
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with close and edit
                HStack(alignment: .top) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(nsColor: .controlBackgroundColor))
                            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                        
                        Image(systemName: asset.iconName)
                            .font(.system(size: 32))
                            .foregroundColor(asset.status.color)
                    }
                    .frame(width: 60, height: 60)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(asset.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 6) {
                            StatusBadge(asset.status)
                            Text(asset.category)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                // Key metrics 2x2 grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    metricBox(title: "购买原价", value: "¥\(String(format: "%.2f", asset.price))", color: .primary)
                    metricBox(title: "净支出", value: "¥\(String(format: "%.2f", net))", color: .primary)
                    metricBox(title: "服役时间", value: "\(days) 天", color: .secondary)
                    metricBox(title: "当前日均", value: "¥\(String(format: "%.2f", daily))/天", color: Color(red: 0.20, green: 0.70, blue: 0.10))
                }
                
                // 目标日均与回本进展
                if let target = asset.targetDailyCost {
                    let progress = AssetCalculator.targetProgress(for: asset)
                    let totalUnits = AssetCalculator.targetTotalUnits(for: asset) ?? 1
                    let currentUnits = (asset.rule == .byCount) ? asset.useCount : days
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("目标日均成本")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("¥\(String(format: "%.2f", target))\(asset.rule.unitString)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(daily <= target ? Color(red: 0.46, green: 0.82, blue: 0.12) : .orange)
                        }
                        
                        // 目标达成进度条 (正向认知模型：从 0% 增长到 100%)
                        VStack(alignment: .leading, spacing: 4) {
                            ProgressView(value: progress, total: 1.0)
                                .tint(daily <= target ? Color(red: 0.46, green: 0.82, blue: 0.12) : .orange)
                            
                            HStack {
                                Text("已回本 \(Int(progress * 100))%")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(daily <= target ? Color(red: 0.46, green: 0.82, blue: 0.12) : .secondary)
                                Spacer()
                                Text("\(currentUnits) / \(totalUnits) \(asset.rule.unitName)")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let rem = remaining {
                            if rem > 0 {
                                HStack {
                                    Text("回本倒计时")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("还需服役 \(rem) \(asset.rule.unitName)")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.orange)
                                }
                            } else {
                                HStack {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(Color(red: 0.46, green: 0.82, blue: 0.12))
                                    Text("恭喜！已达成目标日均，物超所值")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color(red: 0.46, green: 0.82, blue: 0.12))
                                }
                            }
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(nsColor: .controlBackgroundColor))
                    )
                }
                
                // 市场参考价 (若有)
                if let marketPrice = asset.marketPrice {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("预估二手市场价")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("¥\(String(format: "%.2f", marketPrice))")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("账面已折旧")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            let dep = max(0, asset.price - marketPrice)
                            Text("¥\(String(format: "%.2f", dep))")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(nsColor: .controlBackgroundColor))
                    )
                }
                
                // Swift Charts: 日均成本摊薄曲线
                VStack(alignment: .leading, spacing: 8) {
                    Text("日均成本摊薄曲线")
                        .font(.system(size: 13, weight: .semibold))
                    
                    Chart {
                        ForEach(curvePoints) { pt in
                            LineMark(
                                x: .value("天数", pt.day),
                                y: .value("日均成本", pt.costPerDay)
                            )
                            .interpolationMethod(.monotone)
                            .foregroundStyle(Color(red: 0.20, green: 0.70, blue: 0.10))
                            
                            AreaMark(
                                x: .value("天数", pt.day),
                                y: .value("日均成本", pt.costPerDay)
                            )
                            .interpolationMethod(.monotone)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 0.20, green: 0.70, blue: 0.10).opacity(0.2), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                        
                        if let target = asset.targetDailyCost {
                            RuleMark(y: .value("目标日均", target))
                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                .foregroundStyle(.orange)
                                .annotation(position: .top, alignment: .trailing) {
                                    Text("目标 ¥\(String(format: "%.1f", target))")
                                        .font(.system(size: 9))
                                        .foregroundColor(.orange)
                                }
                        }
                    }
                    .frame(height: 120)
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 4)) { value in
                            AxisValueLabel {
                                if let d = value.as(Int.self) {
                                    Text("\(d)天").font(.system(size: 9))
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(values: .automatic(desiredCount: 3)) { value in
                            AxisValueLabel {
                                if let v = value.as(Double.self) {
                                    Text("¥\(Int(v))").font(.system(size: 9))
                                }
                            }
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(nsColor: .controlBackgroundColor))
                )
                
                // 附加项与收益
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("附加账目明细")
                            .font(.system(size: 13, weight: .semibold))
                        Spacer()
                        Button("+ 记一笔") {
                            showAddExpense.toggle()
                        }
                        .font(.caption)
                    }
                    
                    if showAddExpense {
                        HStack {
                            TextField("如：AppleCare+ / 换电池", text: $newExpenseTitle)
                                .textFieldStyle(.roundedBorder)
                            TextField("金额", text: $newExpenseAmount)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 70)
                            Button("添加") {
                                if let amt = Double(newExpenseAmount), !newExpenseTitle.isEmpty {
                                    asset.expenses.append(FinancialRecord(title: newExpenseTitle, amount: amt))
                                    newExpenseTitle = ""
                                    newExpenseAmount = ""
                                    showAddExpense = false
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    if asset.expenses.isEmpty && asset.incomes.isEmpty {
                        Text("无附加成本或回血记录")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(asset.expenses) { exp in
                            HStack {
                                Text(exp.title)
                                    .font(.caption)
                                Spacer()
                                Text("+¥\(String(format: "%.2f", exp.amount))")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.red.opacity(0.8))
                            }
                        }
                        ForEach(asset.incomes) { inc in
                            HStack {
                                Text(inc.title)
                                    .font(.caption)
                                Spacer()
                                Text("-¥\(String(format: "%.2f", inc.amount))")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(nsColor: .controlBackgroundColor))
                )
                
                // 备注
                if !asset.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("备注")
                            .font(.system(size: 13, weight: .semibold))
                        Text(asset.notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(nsColor: .controlBackgroundColor))
                    )
                }
                
                // 底部操作区
                VStack(spacing: 8) {
                    if asset.status == .active {
                        Button {
                            onMarkAsSold()
                        } label: {
                            HStack {
                                Image(systemName: "banknote")
                                Text("标记为已卖出 (二手出清)")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        Button {
                            asset.status = .retired
                            asset.retiredDate = Date()
                        } label: {
                            HStack {
                                Image(systemName: "moon.zzz")
                                Text("标记为已退役 (闲置/报废)")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Button {
                            asset.status = .active
                            asset.retiredDate = nil
                            asset.soldDate = nil
                        } label: {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("恢复为服役中")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Button {
                        onEdit()
                    } label: {
                        HStack {
                            Image(systemName: "pencil")
                            Text("编辑资产属性")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(16)
        }
    }
    
    private func metricBox(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }
}
