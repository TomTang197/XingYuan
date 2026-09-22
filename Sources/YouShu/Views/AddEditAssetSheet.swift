import SwiftUI
import SwiftData

public struct AddEditAssetSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    public var assetToEdit: AssetItem?
    
    @State private var name: String = ""
    @State private var priceString: String = ""
    @State private var purchaseDate: Date = Date()
    @State private var category: String = "数码"
    @State private var tagsString: String = ""
    @State private var iconName: String = "shippingbox.fill"
    
    @State private var status: AssetStatus = .active
    @State private var rule: CostRule = .byDay
    @State private var useCountString: String = "1"
    
    @State private var targetDailyString: String = ""
    @State private var marketPriceString: String = ""
    
    @State private var isPinned: Bool = false
    @State private var excludeFromTotalAssets: Bool = false
    @State private var excludeFromDailyCost: Bool = false
    @State private var notes: String = ""
    
    @State private var showIconPicker: Bool = false
    
    private let categories = ["数码", "出行", "居家", "办公", "影音", "穿搭", "家电", "其他"]
    
    public init(assetToEdit: AssetItem? = nil) {
        self.assetToEdit = assetToEdit
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("基础信息") {
                    HStack {
                        Button {
                            showIconPicker = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: iconName)
                                    .font(.title2)
                                    .foregroundColor(status.color)
                                    .frame(width: 36, height: 36)
                                    .background(Color(nsColor: .controlBackgroundColor))
                                    .cornerRadius(8)
                                Text("更换图标")
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                    
                    TextField("资产名称 (如：MacBook Pro M4 Max)", text: $name)
                    
                    TextField("物品价格 (如：24000.00)", text: $priceString)
                    
                    DatePicker("购买日期", selection: $purchaseDate, displayedComponents: .date)
                    
                    Picker("分类类别", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    
                    TextField("标签 (以逗号或空格分隔)", text: $tagsString)
                }
                
                Section("计算规则与目标") {
                    Picker("成本计算规则", selection: $rule) {
                        ForEach(CostRule.allCases) { r in
                            Text(r.title).tag(r)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if rule == .byCount {
                        TextField("已使用次数", text: $useCountString)
                    }
                    
                    TextField("目标期望日均 (如：15.00，留空则不设定)", text: $targetDailyString)
                    
                    TextField("当前预估市场二手价 (留空则不设定)", text: $marketPriceString)
                }
                
                Section("状态与归属") {
                    Picker("当前状态", selection: $status) {
                        ForEach(AssetStatus.allCases) { s in
                            Text(s.title).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Toggle("置顶该资产", isOn: $isPinned)
                    Toggle("不计入总资产总览", isOn: $excludeFromTotalAssets)
                    Toggle("不计入全局总日均成本", isOn: $excludeFromDailyCost)
                }
                
                Section("备注") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 60)
                }
            }
            .formStyle(.grouped)
            .navigationTitle(assetToEdit == nil ? "新增资产" : "编辑资产")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        save()
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || Double(priceString) == nil)
                }
            }
            .sheet(isPresented: $showIconPicker) {
                SFIconPicker(selectedIcon: $iconName)
            }
            .onAppear {
                if let asset = assetToEdit {
                    name = asset.name
                    priceString = String(format: "%.2f", asset.price)
                    purchaseDate = asset.purchaseDate
                    category = asset.category
                    tagsString = asset.tags.joined(separator: ", ")
                    iconName = asset.iconName
                    status = asset.status
                    rule = asset.rule
                    useCountString = "\(asset.useCount)"
                    targetDailyString = asset.targetDailyCost.map { String(format: "%.2f", $0) } ?? ""
                    marketPriceString = asset.marketPrice.map { String(format: "%.2f", $0) } ?? ""
                    isPinned = asset.isPinned
                    excludeFromTotalAssets = asset.excludeFromTotalAssets
                    excludeFromDailyCost = asset.excludeFromDailyCost
                    notes = asset.notes
                }
            }
        }
        .frame(minWidth: 480, minHeight: 560)
    }
    
    private func save() {
        let price = Double(priceString) ?? 0.0
        let targetDaily = Double(targetDailyString)
        let marketPrice = Double(marketPriceString)
        let useCount = Int(useCountString) ?? 1
        let tags = tagsString
            .components(separatedBy: CharacterSet(charactersIn: ",， "))
            .filter { !$0.isEmpty }
        
        if let asset = assetToEdit {
            asset.name = name
            asset.price = price
            asset.purchaseDate = purchaseDate
            asset.category = category
            asset.tags = tags
            asset.iconName = iconName
            asset.status = status
            asset.rule = rule
            asset.useCount = useCount
            asset.targetDailyCost = targetDaily
            asset.marketPrice = marketPrice
            asset.isPinned = isPinned
            asset.excludeFromTotalAssets = excludeFromTotalAssets
            asset.excludeFromDailyCost = excludeFromDailyCost
            asset.notes = notes
            asset.updatedAt = Date()
        } else {
            let newAsset = AssetItem(
                name: name,
                price: price,
                purchaseDate: purchaseDate,
                category: category,
                tags: tags,
                iconName: iconName,
                status: status,
                rule: rule,
                useCount: useCount,
                targetDailyCost: targetDaily,
                marketPrice: marketPrice,
                isPinned: isPinned,
                excludeFromTotalAssets: excludeFromTotalAssets,
                excludeFromDailyCost: excludeFromDailyCost,
                notes: notes
            )
            modelContext.insert(newAsset)
        }
        
        try? modelContext.save()
    }
}
