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
        let enteredSoldPrice = Double(soldPriceString) ?? 0.0
        let days = max(1, Calendar.current.dateComponents([.day], from: asset.purchaseDate, to: soldDate).day ?? 1)
        let simulatedNet = asset.price - enteredSoldPrice
        let simulatedDaily = simulatedNet / Double(days)
        
        NavigationStack {
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    Image(systemName: asset.iconName)
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                        .frame(width: 50, height: 50)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(asset.name)
                            .font(.headline)
                        Text("买入价 ¥\(String(format: "%.2f", asset.price))  |  当前日均 ¥\(String(format: "%.2f", currentDaily))/天")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(nsColor: .controlBackgroundColor)))
                
                Form {
                    TextField("二手出清回血金额 (¥)", text: $soldPriceString)
                    DatePicker("卖出日期", selection: $soldDate, displayedComponents: .date)
                }
                .formStyle(.grouped)
                
                // 即时日均暴降成就感反馈
                VStack(spacing: 8) {
                    Text("二手回血后净日均成本变化")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 16) {
                        VStack {
                            Text("原日均")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("¥\(String(format: "%.2f", currentDaily))")
                                .font(.system(size: 16, weight: .bold))
                                .strikethrough()
                                .foregroundColor(.secondary)
                        }
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(.orange)
                        
                        VStack {
                            Text("最终日均 (已冲抵)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("¥\(String(format: "%.2f", max(0, simulatedDaily)))/天")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.orange.opacity(0.1)))
                }
                
                Spacer()
                
                HStack {
                    Button("取消") { dismiss() }
                    Spacer()
                    Button("确认出清卖出") {
                        onConfirm(enteredSoldPrice, soldDate)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .disabled(Double(soldPriceString) == nil)
                }
            }
            .padding(20)
            .navigationTitle("标记为已卖出")
        }
        .frame(width: 420, height: 440)
    }
}
