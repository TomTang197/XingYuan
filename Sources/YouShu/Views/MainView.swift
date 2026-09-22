import SwiftUI
import SwiftData

public struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allAssets: [AssetItem]
    
    @State private var sidebarSelection: SidebarDestination = .status(.active)
    @State private var searchText: String = ""
    @State private var viewMode: String = "grid" // "grid" or "table"
    @State private var sortOption: String = "dailyAsc"
    
    @State private var selectedAsset: AssetItem?
    @State private var showInspector: Bool = false
    @State private var showAddAssetSheet: Bool = false
    @State private var assetToEdit: AssetItem?
    @State private var assetToMarkAsSold: AssetItem?
    
    public init() {}
    
    // 过滤与排序后的资产列表
    private var filteredAssets: [AssetItem] {
        var list = allAssets
        
        // 侧边栏范围过滤
        switch sidebarSelection {
        case .status(let s):
            list = list.filter { $0.status == s }
        case .category(let c):
            list = list.filter { $0.category == c }
        default:
            break
        }
        
        // 搜索关键词过滤
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            list = list.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // 排序规则
        list.sort { a, b in
            if a.isPinned != b.isPinned {
                return a.isPinned && !b.isPinned
            }
            switch sortOption {
            case "dailyAsc":
                return AssetCalculator.dailyCost(for: a) < AssetCalculator.dailyCost(for: b)
            case "dailyDesc":
                return AssetCalculator.dailyCost(for: a) > AssetCalculator.dailyCost(for: b)
            case "priceDesc":
                return a.price > b.price
            case "dateDesc":
                return a.purchaseDate > b.purchaseDate
            default:
                return a.purchaseDate > b.purchaseDate
            }
        }
        
        return list
    }
    
    public var body: some View {
        NavigationSplitView {
            SidebarView(selection: $sidebarSelection)
        } detail: {
            destinationView
                .inspector(isPresented: $showInspector) {
                    if let asset = selectedAsset {
                        AssetInspectorView(
                            asset: asset,
                            onClose: {
                                withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                                    showInspector = false
                                    selectedAsset = nil
                                }
                            },
                            onEdit: {
                                assetToEdit = asset
                            },
                            onMarkAsSold: {
                                assetToMarkAsSold = asset
                            }
                        )
                        .inspectorColumnWidth(min: 280, ideal: 340, max: 440)
                    } else {
                        VStack(spacing: 0) {
                            HStack {
                                Spacer()
                                Button {
                                    withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                                        showInspector = false
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 19))
                                        .foregroundColor(Color(nsColor: .secondaryLabelColor))
                                }
                                .buttonStyle(.borderless)
                                .contentShape(Rectangle())
                                .frame(width: 28, height: 28)
                                .help("关闭详情面板 (Esc)")
                                .keyboardShortcut(.cancelAction)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            
                            Spacer()
                            
                            VStack(spacing: 8) {
                                Image(systemName: "sidebar.right")
                                    .font(.system(size: 36))
                                    .foregroundColor(.secondary.opacity(0.5))
                                Text("未选中资产")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("从列表选择任意卡片查看详细日均曲线")
                                    .font(.caption)
                                    .foregroundColor(.secondary.opacity(0.8))
                            }
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
        }
        .searchable(text: $searchText, placement: .toolbar, prompt: "搜索资产名称、类别或标签")
        .sheet(isPresented: $showAddAssetSheet) {
            AddEditAssetSheet()
        }
        .sheet(item: $assetToEdit) { asset in
            AddEditAssetSheet(assetToEdit: asset)
        }
        .sheet(item: $assetToMarkAsSold) { asset in
            MarkAsSoldSheet(asset: asset) { soldPrice, soldDate in
                asset.status = .sold
                asset.soldPrice = soldPrice
                asset.soldDate = soldDate
                try? modelContext.save()
            }
        }
        .onChange(of: selectedAsset) { _, newAsset in
            if newAsset != nil {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                    showInspector = true
                }
            }
        }
        .onChange(of: showInspector) { _, isShowing in
            if !isShowing && selectedAsset != nil {
                selectedAsset = nil
            }
        }
        .onAppear {
            SampleData.loadSampleDataIfNeeded(context: modelContext)
        }
    }
    
    @ViewBuilder
    private var destinationView: some View {
        switch sidebarSelection {
        case .wishlist:
            WishlistView()
        case .trends:
            TrendsView()
        case .settings:
            SettingsView()
        case .allAssets, .status, .category:
            assetsListView
        }
    }
    
    private var currentFilterStatus: AssetStatus? {
        if case .status(let s) = sidebarSelection {
            return s
        }
        return nil
    }
    
    private var assetsListView: some View {
        let stats = AssetCalculator.calculateOverview(assets: allAssets, filterStatus: currentFilterStatus)
        
        return ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // 顶部资产总览卡片 (还原原图 1 与原图 27)
                OverviewCardView(stats: stats)
                
                // 筛选与工具栏
                HStack {
                    // 状态筛选药丸组
                    statusPillGroup
                    
                    Spacer()
                    
                    // 排序下拉菜单
                    Menu {
                        Picker("排序", selection: $sortOption) {
                            Label("日均成本：从低到高", systemImage: "arrow.up").tag("dailyAsc")
                            Label("日均成本：从高到低", systemImage: "arrow.down").tag("dailyDesc")
                            Label("购买价格：从高到低", systemImage: "dollarsign.circle").tag("priceDesc")
                            Label("购买时间：从新到旧", systemImage: "calendar").tag("dateDesc")
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 13))
                    }
                    .menuStyle(.borderlessButton)
                    .frame(width: 32)
                    
                    // 视图切换：网格 vs 表格
                    Picker("", selection: $viewMode) {
                        Image(systemName: "square.grid.2x2").tag("grid")
                        Image(systemName: "list.bullet").tag("table")
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 80)
                    
                    // 新增资产按钮
                    Button {
                        showAddAssetSheet = true
                    } label: {
                        Label("新增", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0.46, green: 0.82, blue: 0.12))
                }
                
                // 资产主展示区 (网格或表格)
                if viewMode == "grid" {
                    AssetGridView(
                        assets: filteredAssets,
                        selectedAsset: $selectedAsset,
                        onEdit: { assetToEdit = $0 },
                        onMarkAsSold: { assetToMarkAsSold = $0 },
                        onMarkAsRetired: {
                            $0.status = .retired
                            $0.retiredDate = Date()
                            try? modelContext.save()
                        },
                        onDelete: {
                            if selectedAsset?.id == $0.id { selectedAsset = nil }
                            modelContext.delete($0)
                            try? modelContext.save()
                        }
                    )
                } else {
                    AssetTableView(
                        assets: filteredAssets,
                        selectedAsset: $selectedAsset,
                        onEdit: { assetToEdit = $0 },
                        onMarkAsSold: { assetToMarkAsSold = $0 },
                        onMarkAsRetired: {
                            $0.status = .retired
                            $0.retiredDate = Date()
                            try? modelContext.save()
                        },
                        onDelete: {
                            if selectedAsset?.id == $0.id { selectedAsset = nil }
                            modelContext.delete($0)
                            try? modelContext.save()
                        }
                    )
                    .frame(minHeight: 400)
                }
            }
            .padding(20)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddAssetSheet = true
                } label: {
                    Label("新增资产", systemImage: "plus")
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            ToolbarItem(placement: .automatic) {
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                        showInspector.toggle()
                    }
                } label: {
                    Label("检查器", systemImage: "sidebar.right")
                }
            }
        }
    }
    
    private var statusPillGroup: some View {
        HStack(spacing: 8) {
            pillButton(title: "全部", isSelected: isAllSelected) {
                sidebarSelection = .allAssets
            }
            
            pillButton(title: "服役中", isSelected: sidebarSelection == .status(.active)) {
                sidebarSelection = .status(.active)
            }
            
            pillButton(title: "已退役", isSelected: sidebarSelection == .status(.retired)) {
                sidebarSelection = .status(.retired)
            }
            
            pillButton(title: "已卖出", isSelected: sidebarSelection == .status(.sold)) {
                sidebarSelection = .status(.sold)
            }
        }
    }
    
    private var isAllSelected: Bool {
        if case .allAssets = sidebarSelection { return true }
        return false
    }
    
    private func pillButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.primary : Color(nsColor: .controlBackgroundColor))
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color(nsColor: .separatorColor).opacity(0.6), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
