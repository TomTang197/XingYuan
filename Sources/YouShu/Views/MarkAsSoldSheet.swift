import SwiftUI

public struct MarkAsSoldSheet: View {
    @Environment(\.dismiss) private var dismiss
    public let asset: AssetItem
    public var onConfirm: (Double, Date) -> Void
    
    @State private var soldPriceString: String = ""
    @State private var soldDate: Date = Date()
    
    public init(asset: AssetItem, onConfirm: @escaping (Double, Date) -> Void) {
        self.asset = asset
        self.onConfirm = onConfirm
    }
    
    public var body: some View {
        let currentDaily = AssetCalculator.dailyCost(for: asset)
        let grossCost = AssetCalculator.grossCost(for: asset)
        let enteredSoldPrice = Double(soldPriceString) ?? 0.0
        let hasEnteredPrice = Double(soldPriceString) != nil
        
        let cal = Calendar.current
        let start = cal.startOfDay(for: asset.purchaseDate)
        let end = cal.startOfDay(for: soldDate)
        let days = max(1, cal.dateComponents([.day], from: start, to: end).day ?? 1)
        
        let simulatedNet = grossCost - enteredSoldPrice
        let simulatedDaily = (asset.rule == .byCount) ? (simulatedNet / Double(max(1, asset.useCount))) : (simulatedNet / Double(days))
        
        NavigationStack {
            VStack(spacing: 16) {
                // 顶部资产基本信息卡片
                HStack(spacing: 12) {
                    Image(systemName: asset.iconName)
                        .font(.system(size: 26))
                        .foregroundColor(.orange)
                        .frame(width: 48, height: 48)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(asset.name)
                            .font(.system(size: 15, weight: .semibold))
                        HStack(spacing: 6) {
                            Text("总投入 ¥\(String(format: "%.2f", grossCost))")
                            Text("|")
                                .foregroundColor(Color(nsColor: .separatorColor))
                            Text("当前日均 ¥\(String(format: "%.2f", currentDaily))\(asset.rule.unitString)")
                        }
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(nsColor: .controlBackgroundColor)))
                
                // 输入表单
                Form {
                    TextField("二手卖出价 (¥)", text: $soldPriceString)
                        .textFieldStyle(.roundedBorder)
                    DatePicker("卖出成交日期", selection: $soldDate, displayedComponents: .date)
                }
                .formStyle(.grouped)
                .padding(.horizontal, -8)
                
                // 智能多场景与日均冲抵反馈
                VStack(spacing: 10) {
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("出清前日均")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("¥\(String(format: "%.2f", currentDaily))")
                                .font(.system(size: 15, weight: .semibold))
                                .strikethrough()
                                .foregroundColor(.secondary)
                        }
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("结清后日均 (已冲抵)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            let valueColor: Color = simulatedDaily < 0 ? Color(red: 0.46, green: 0.82, blue: 0.12) : (abs(simulatedDaily) < 0.001 ? .blue : .orange)
                            
                            Text("¥\(String(format: "%.2f", simulatedDaily))\(asset.rule.unitString)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(valueColor)
                        }
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    // 动态场景解说
                    HStack(alignment: .top, spacing: 8) {
                        if !hasEnteredPrice {
                            Image(systemName: "info.circle")
                                .foregroundColor(.secondary)
                            Text("请输入卖出金额，系统将智能判定折旧、平价或理财盈利场景。")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else if enteredSoldPrice == 0 {
                            Image(systemName: "trash")
                                .foregroundColor(.secondary)
                            Text("0元报废/赠送：无残值回血，全部投入 ¥\(String(format: "%.2f", grossCost)) 计入历史沉没成本。")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else if abs(simulatedNet) < 0.001 {
                            Image(systemName: "equal.circle.fill")
                                .foregroundColor(.blue)
                            Text("✨ 平价全额回血：二手售价完全覆盖累计投入，持有 \(days) 天实现完全 0 元白嫖！")
                                .font(.caption)
                                .foregroundColor(.blue)
                        } else if simulatedNet < 0 {
                            Image(systemName: "sparkles")
                                .foregroundColor(Color(red: 0.46, green: 0.82, blue: 0.12))
                            Text("🎉 溢价理财卖出：售价高于投入，净赚 ¥\(String(format: "%.2f", abs(simulatedNet)))！折合每日净收益 ¥\(String(format: "%.2f", abs(simulatedDaily)))。")
                                .font(.caption)
                                .foregroundColor(Color(red: 0.46, green: 0.82, blue: 0.12))
                        } else {
                            let recRate = grossCost > 0 ? Int((enteredSoldPrice / grossCost) * 100) : 0
                            Image(systemName: "arrow.down.right.circle.fill")
                                .foregroundColor(.orange)
                            Text("📉 正常折旧出清：回血率 \(recRate)%，实际承担折损 ¥\(String(format: "%.2f", simulatedNet))，日均成本大幅摊薄。")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(nsColor: .controlBackgroundColor))
                )
                
                Spacer()
                
                // 底部按钮
                HStack {
                    Button("取消") { dismiss() }
                        .keyboardShortcut(.cancelAction)
                    
                    Spacer()
                    
                    Button(asset.status == .sold ? "保存二手卖出价" : "确认出清卖出") {
                        onConfirm(enteredSoldPrice, soldDate)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .disabled(Double(soldPriceString) == nil)
                }
            }
            .padding(18)
            .navigationTitle(asset.status == .sold ? "修改二手卖出价" : "标记为已卖出 (录入二手卖出价)")
            .onAppear {
                if let sp = asset.soldPrice {
                    soldPriceString = String(format: "%.2f", sp)
                }
                if let sd = asset.soldDate {
                    soldDate = sd
                }
            }
        }
        .frame(width: 440, height: 460)
    }
}
