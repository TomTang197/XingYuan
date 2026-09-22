import SwiftUI
import SwiftData

public enum SidebarDestination: Hashable {
    case allAssets
    case status(AssetStatus)
    case category(String)
    case wishlist
    case trends
    case settings
}

public struct SidebarView: View {
    @Binding public var selection: SidebarDestination
    @Query private var assets: [AssetItem]
    @Query private var wishes: [WishItem]
    
    private let defaultCategories = ["数码", "出行", "居家", "办公", "影音", "穿搭", "家电"]
    
    public init(selection: Binding<SidebarDestination>) {
        self._selection = selection
    }
    
    public var body: some View {
        List(selection: $selection) {
            Section("资产管理") {
                NavigationLink(value: SidebarDestination.allAssets) {
                    HStack {
                        Label("全部资产", systemImage: "square.grid.2x2.fill")
                        Spacer()
                        Text("\(assets.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                NavigationLink(value: SidebarDestination.status(.active)) {
                    HStack {
                        Label {
                            Text("服役中")
                        } icon: {
                            Circle().fill(AssetStatus.active.color).frame(width: 8, height: 8)
                        }
                        Spacer()
                        let count = assets.filter { $0.status == .active }.count
                        Text("\(count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                NavigationLink(value: SidebarDestination.status(.retired)) {
                    HStack {
                        Label {
                            Text("已退役")
                        } icon: {
                            Circle().fill(AssetStatus.retired.color).frame(width: 8, height: 8)
                        }
                        Spacer()
                        let count = assets.filter { $0.status == .retired }.count
                        Text("\(count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                NavigationLink(value: SidebarDestination.status(.sold)) {
                    HStack {
                        Label {
                            Text("已卖出")
                        } icon: {
                            Circle().fill(AssetStatus.sold.color).frame(width: 8, height: 8)
                        }
                        Spacer()
                        let count = assets.filter { $0.status == .sold }.count
                        Text("\(count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section("分类过滤") {
                ForEach(defaultCategories, id: \.self) { cat in
                    NavigationLink(value: SidebarDestination.category(cat)) {
                        HStack {
                            Label(cat, systemImage: iconForCategory(cat))
                            Spacer()
                            let count = assets.filter { $0.category == cat }.count
                            if count > 0 {
                                Text("\(count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            
            Section("洞悉与计划") {
                NavigationLink(value: SidebarDestination.wishlist) {
                    HStack {
                        Label("心愿单", systemImage: "gift.fill")
                            .foregroundColor(.pink)
                        Spacer()
                        Text("\(wishes.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                NavigationLink(value: SidebarDestination.trends) {
                    Label("趋势与洞悉", systemImage: "chart.xyaxis.line")
                        .foregroundColor(Color(red: 0.20, green: 0.70, blue: 0.10))
                }
            }
            
            Section("系统") {
                NavigationLink(value: SidebarDestination.settings) {
                    Label("设置与备份", systemImage: "gear")
                }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 190)
    }
    
    private func iconForCategory(_ category: String) -> String {
        switch category {
        case "数码": return "laptopcomputer"
        case "出行": return "car.fill"
        case "居家": return "house.fill"
        case "办公": return "briefcase.fill"
        case "影音": return "headphones"
        case "穿搭": return "tshirt.fill"
        case "家电": return "washer.fill"
        default: return "tag.fill"
        }
    }
}
