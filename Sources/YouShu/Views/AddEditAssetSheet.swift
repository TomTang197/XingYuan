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
    @State private var soldPriceString: String = ""
    @State private var soldDate: Date = Date()
    @State private var rule: CostRule = .byDay
    @State private var useCountString: String = "1"
    
    @State private var targetDailyString: String = ""
    @State private var targetMode: TargetCostMode = .none
    @State private var targetDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var computedDaysRequired: Int? = nil
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
                    
                    Picker("目标设定模式", selection: $targetMode) {
                        ForEach(TargetCostMode.allCases) { m in
                            Text(m.title).tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if targetMode == .byPrice || targetMode == .custom {
                        TextField("目标期望日均 (如：15.00)", text: $targetDailyString)
                            .onChange(of: targetDailyString) { _, val in
                                if let target = Double(val), target > 0, let p = Double(priceString), p > 0 {
                                    computedDaysRequired = Int(ceil(p / target))
                                } else {
                                    computedDaysRequired = nil
                                }
                            }
                        
                        if let daysReq = computedDaysRequired {
                            Text("预计需服役 \(daysReq) \(rule.unitName) 达成目标")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    } else if targetMode == .byDate {
                        DatePicker("目标达成日期", selection: $targetDate, in: purchaseDate..., displayedComponents: .date)
                            .onChange(of: targetDate) { _, newDate in
                                let days = max(1, Calendar.current.dateComponents([.day], from: purchaseDate, to: newDate).day ?? 1)
                                if let p = Double(priceString), p > 0 {
                                    let daily = p / Double(days)
                                    targetDailyString = String(format: "%.2f", daily)
                                }
                            }
                        if !targetDailyString.isEmpty {
                            Text("到期时日均成本将降至: ¥\(targetDailyString)/天")
                                .font(.caption)
                                .foregroundColor(Color(red: 0.46, green: 0.82, blue: 0.12))
                        }
                    }
                    
                    TextField("当前预估二手市场价 (选填)", text: $marketPriceString)
                }
                
                Section("状态与归属") {
                    Picker("当前状态", selection: $status) {
                        ForEach(AssetStatus.allCases) { s in
                            Text(s.title).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if status == .sold {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("二手出清信息")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.orange)
                            
                            TextField("二手卖出价 (¥)", text: $soldPriceString)
                                .textFieldStyle(.roundedBorder)
                            
                            DatePicker("卖出成交日期", selection: $soldDate, displayedComponents: .date)
                            
                            if let sp = Double(soldPriceString), let bp = Double(priceString) {
                                let diff = sp - bp
                                if diff > 0 {
                                    Text("🎉 溢价理财卖出：净赚 ¥\(String(format: "%.2f", diff))")
                                        .font(.caption)
                                        .foregroundColor(Color(red: 0.46, green: 0.82, blue: 0.12))
                                } else if abs(diff) < 0.01 {
                                    Text("✨ 平价全额回血：0元白嫖")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                } else {
                                    Text("📉 正常折旧出清：净折损 ¥\(String(format: "%.2f", abs(diff)))")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
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
                    if asset.targetDailyCost != nil {
                        targetMode = .byPrice
                        if let t = asset.targetDailyCost, t > 0 {
                            computedDaysRequired = Int(ceil(asset.price / t))
                        }
                    }
                    if let td = asset.targetDate {
                        targetDate = td
                        targetMode = .byDate
                    }
                    marketPriceString = asset.marketPrice.map { String(format: "%.2f", $0) } ?? ""
                    isPinned = asset.isPinned
                    excludeFromTotalAssets = asset.excludeFromTotalAssets
                    excludeFromDailyCost = asset.excludeFromDailyCost
                    if let sp = asset.soldPrice {
                        soldPriceString = String(format: "%.2f", sp)
                    }
                    if let sd = asset.soldDate {
                        soldDate = sd
                    }
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
        let soldPrice = (status == .sold) ? Double(soldPriceString) : nil
        let finalSoldDate = (status == .sold) ? soldDate : nil
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
            asset.soldPrice = soldPrice
            asset.soldDate = finalSoldDate
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
                soldDate: finalSoldDate,
                soldPrice: soldPrice,
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
