import SwiftUI
import SwiftData
import UniformTypeIdentifiers

public struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var assets: [AssetItem]
    @Query private var wishes: [WishItem]
    
    @AppStorage("currencySymbol") private var currencySymbol: String = "¥"
    @AppStorage("decimalPlaces") private var decimalPlaces: Int = 2
    @AppStorage("useThousandsSeparator") private var useThousandsSeparator: Bool = true
    @AppStorage("defaultViewMode") private var defaultViewMode: String = "grid"
    
    @State private var alertMessage: String?
    @State private var showAlert: Bool = false
    
    public init() {}
    
    public var body: some View {
        Form {
            Section("数据与备份") {
                Button("载入预置样例数据 (包含截图中 10 件真实设备)") {
                    SampleData.loadSampleData(context: modelContext)
                    alertMessage = "成功载入 10 件样例资产与 2 件心愿数据！"
                    showAlert = true
                }
                
                Button("导出完整数据备份 (JSON)") {
                    exportJSON()
                }
                
                Button("导出资产明细表格 (CSV)") {
                    exportCSV()
                }
                
                Button("从 JSON 备份恢复数据...") {
                    importJSON()
                }
                
                Button("清空所有数据", role: .destructive) {
                    clearAll()
                }
            }
            
            Section("数值与单位") {
                Picker("货币符号", selection: $currencySymbol) {
                    Text("¥ 人民币 (CNY)").tag("¥")
                    Text("$ 美元 (USD)").tag("$")
                    Text("€ 欧元 (EUR)").tag("€")
                    Text("£ 英镑 (GBP)").tag("£")
                }
                
                Picker("小数点位数", selection: $decimalPlaces) {
                    Text("保留 2 位 (¥0.00)").tag(2)
                    Text("保留 1 位 (¥0.0)").tag(1)
                    Text("不保留小数 (¥0)").tag(0)
                }
                
                Toggle("使用千位分隔符 (10,000.00)", isOn: $useThousandsSeparator)
            }
            
            Section("外观与偏好") {
                Picker("默认首页视图", selection: $defaultViewMode) {
                    Text("卡片网格模式 (Card Grid)").tag("grid")
                    Text("表格清单模式 (Table View)").tag("table")
                }
            }
            
            Section("关于 有数 (YouShu) Mac 版") {
                VStack(alignment: .leading, spacing: 6) {
                    Text("有数 (YouShu) - 个人资产日均成本追踪工具")
                        .font(.headline)
                    Text("核心理念：物尽其用，买得贵不如用得久。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("数据完全存储于本地 SwiftData 数据库，离线优先，零隐私泄露风险。")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .formStyle(.grouped)
        .padding()
        .alert("提示", isPresented: $showAlert) {
            Button("好的") {}
        } message: {
            Text(alertMessage ?? "")
        }
    }
    
    private func exportJSON() {
        do {
            let data = try DataExporter.exportToJSON(assets: assets, wishes: wishes)
            let panel = NSSavePanel()
            panel.allowedContentTypes = [.json]
            panel.nameFieldStringValue = "youshu_backup_\(Date().formatted(date: .numeric, time: .omitted)).json"
            if panel.runModal() == .OK, let url = panel.url {
                try data.write(to: url)
                alertMessage = "数据已成功备份至: \(url.lastPathComponent)"
                showAlert = true
            }
        } catch {
            alertMessage = "导出失败: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func exportCSV() {
        let csv = DataExporter.exportToCSV(assets: assets)
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.commaSeparatedText]
        panel.nameFieldStringValue = "youshu_assets_\(Date().formatted(date: .numeric, time: .omitted)).csv"
        if panel.runModal() == .OK, let url = panel.url {
            try? csv.write(to: url, atomically: true, encoding: .utf8)
            alertMessage = "CSV 已成功导出至: \(url.lastPathComponent)"
            showAlert = true
        }
    }
    
    private func importJSON() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url, let data = try? Data(contentsOf: url) {
            do {
                let counts = try DataExporter.importFromJSON(data: data, context: modelContext)
                alertMessage = "成功恢复 \(counts.assetCount) 件资产与 \(counts.wishCount) 件心愿！"
                showAlert = true
            } catch {
                alertMessage = "导入恢复失败: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
    
    private func clearAll() {
        for a in assets { modelContext.delete(a) }
        for w in wishes { modelContext.delete(w) }
        try? modelContext.save()
        alertMessage = "所有本地数据已清空。"
        showAlert = true
    }
}
