import SwiftUI
import SwiftData

public struct WishlistView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WishItem.createdAt, order: .reverse) private var wishes: [WishItem]
    
    @State private var showAddWish: Bool = false
    @State private var wishNameToConvert: WishItem?
    
    // New wish fields
    @State private var newName: String = ""
    @State private var newPrice: String = ""
    @State private var newTargetDaily: String = ""
    @State private var newCategory: String = "数码"
    @State private var newNotes: String = ""
    @State private var newIcon: String = "sparkles"
    
    public init() {}
    
    public var body: some View {
        let totalWishValue = wishes.reduce(0.0) { $0 + $1.estimatedPrice }
        
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 心愿总值概览卡片 (还原原图2/3)
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("心愿总值")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        
                        Text("¥\(String(format: "%.2f", totalWishValue))")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("心愿数量: \(wishes.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(red: 0.90, green: 0.95, blue: 0.85))
                            .frame(width: 72, height: 72)
                        
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color(red: 0.46, green: 0.82, blue: 0.12))
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(nsColor: .separatorColor).opacity(0.4), lineWidth: 1)
                )
                
                // Toolbar
                HStack {
                    Text("心愿清单")
                        .font(.headline)
                    Spacer()
                    Button {
                        showAddWish = true
                    } label: {
                        Label("添加心愿", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                // 心愿列表
                if wishes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "gift")
                            .font(.system(size: 56))
                            .foregroundColor(.secondary.opacity(0.4))
                        
                        Text("空空如也")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("点击右上角 + 添加想买的心愿装备\n通过期望日均计算“冷静期”")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, minHeight: 260)
                    .padding()
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280, maximum: 380), spacing: 16)], spacing: 16) {
                        ForEach(wishes) { wish in
                            wishCard(wish: wish)
                        }
                    }
                }
            }
            .padding(24)
        }
        .sheet(isPresented: $showAddWish) {
            addWishSheet
        }
    }
    
    private func wishCard(wish: WishItem) -> some View {
        let targetDays = wish.targetDailyCost.flatMap { target -> Int? in
            guard target > 0 else { return nil }
            return Int(ceil(wish.estimatedPrice / target))
        }
        
        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: wish.iconName)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .frame(width: 44, height: 44)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(wish.name)
                        .font(.system(size: 15, weight: .semibold))
                    Text("预估 ¥\(String(format: "%.2f", wish.estimatedPrice))")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            // 冷静期公式与心理核算
            if let target = wish.targetDailyCost, let days = targetDays {
                HStack(spacing: 8) {
                    Image(systemName: "hourglass.badge.plus")
                        .foregroundColor(.orange)
                        .font(.system(size: 16))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text("买前冷静期: 需使用 \(days) 天")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.orange)
                            Spacer()
                            let years = Double(days) / 365.0
                            Text(String(format: "约 %.1f 年", years))
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Text("按期望日均 ¥\(String(format: "%.2f", target))/天 测算回本年限")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.orange.opacity(0.08)))
            }
            
            if !wish.notes.isEmpty {
                Text(wish.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Divider()
            
            HStack {
                Button(role: .destructive) {
                    modelContext.delete(wish)
                    try? modelContext.save()
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button {
                    convertToAsset(wish: wish)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("已购入，转在役")
                    }
                    .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(nsColor: .separatorColor).opacity(0.4), lineWidth: 1)
        )
    }
    
    private func convertToAsset(wish: WishItem) {
        let asset = AssetItem(
            name: wish.name,
            price: wish.estimatedPrice,
            purchaseDate: Date(),
            category: wish.category,
            tags: wish.tags,
            iconName: wish.iconName,
            status: .active,
            targetDailyCost: wish.targetDailyCost,
            notes: wish.notes
        )
        modelContext.insert(asset)
        modelContext.delete(wish)
        try? modelContext.save()
    }
    
    private var addWishSheet: some View {
        NavigationStack {
            Form {
                TextField("心愿名称 (如：Sony A7M5)", text: $newName)
                TextField("预估价格 (如：17999.00)", text: $newPrice)
                TextField("期望日均成本 (如：20.00，用于计算冷静期天数)", text: $newTargetDaily)
                TextField("备注或购买动机", text: $newNotes)
            }
            .formStyle(.grouped)
            .navigationTitle("添加心愿")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { showAddWish = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        if let price = Double(newPrice), !newName.isEmpty {
                            let wish = WishItem(
                                name: newName,
                                estimatedPrice: price,
                                category: newCategory,
                                targetDailyCost: Double(newTargetDaily),
                                notes: newNotes
                            )
                            modelContext.insert(wish)
                            try? modelContext.save()
                            newName = ""
                            newPrice = ""
                            newTargetDaily = ""
                            newNotes = ""
                            showAddWish = false
                        }
                    }
                    .disabled(newName.isEmpty || Double(newPrice) == nil)
                }
            }
        }
        .frame(width: 400, height: 320)
    }
}
