# ✨ 星元 (XingYuan)

> **物尽其用，星火汇元。买得贵不如用得久。**  
> 原生 macOS 个人资产与日均成本精算管理工具，实时追踪物品摊薄成本，助你建立理性的消费观与物尽其用的生活哲学。

[![Platform](https://img.shields.io/badge/Platform-macOS%2014.0%2B-blue?logo=apple)](https://apple.com)
[![Swift](https://img.shields.io/badge/Swift-6.4%20%7C%20SwiftUI-orange?logo=swift)](https://swift.org)
[![Storage](https://img.shields.io/badge/Database-SwiftData-purple)]()
[![Widgets](https://img.shields.io/badge/Widgets-WidgetKit%20%2B%20AppIntents-brightgreen)]()
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## 🌟 核心功能特性

### 1. 实时日均成本推算模型 (Daily Cost Amortization)
- **每一天的价值看得见**：自动根据买入价格与服役天数（$D = \max(1, \text{Today} - \text{PurchaseDate})$）精准核算当前真实的日均使用成本：
  $$\text{DailyCost} = \frac{P_{\text{buy}} + \sum \text{Expenses} - \sum \text{Incomes}}{D}$$
- **目标价倒计时胶囊**：为资产设定心仪的日均目标价（例如每天 2 元），系统自动推算剩余回本天数与达成日期。

### 2. 二手出清多场景经济核算 (Sold Asset Economics)
告别传统记账软件在二手转卖时的死板核算，星元支持 5 大真实出清场景：
- **场景 1：折价卖出**（二手残值冲抵，真实核算在役期间的净折旧损益）。
- **场景 2：平价全额回血**（二手卖出价等于投入，日均成本归零，达成「0元白嫖」）。
- **场景 3：溢价理财盈利**（转卖价格高于买入投入，日均成本呈现负值，如 `¥-6.00/天`，在总资产中冲抵其他开销）。
- **场景 4：零元出清 / 报废**（全额计入沉没成本出清）。
- **场景 5：按次计费模式**（支持健身卡、门票等按次出清核算）。

### 3. 双层原生小组件系统 (Double-Tier Widgets)
无需打开主窗口，随时随地掌握资产动态：
- **屏幕顶部状态栏 (MenuBarExtra)**：常驻显示今日在役总日均，轻点弹出 Mini 看板查看 Top 5 单品明细并支持即时切换排序。
- **macOS 原生壁纸桌面小组件 (WidgetKit Extension)**：严格遵循 Apple 规范打造的桌面壁纸小组件（支持 **Small 1×1**、**Medium 2×1**、**Large 2×2**），可直接拖放到桌面壁纸常驻运行。

### 4. 6 组多维度动态排序 (6 Customizable Ranking Rules)
小组件与菜单栏提供 6 组多视角排行榜：
- **最低每日 (物超所值)**：使用最充分、摊薄最极致的常青物品。
- **最高每日 (耗资最大)**：日均消耗最高的大件，审视利用率是否充足。
- **最新购买 (最新入手)**：按入手时间倒序，直观回顾新入装备。
- **服役最久 (陪伴最长)**：按服役天数倒序，致敬陪伴岁月最久的物件。
- **最高原价 (重资产配置)**：按买入原价降序，把握核心资产分布。
- **最低原价 (超值小确幸)**：按买入原价升序，回顾高性价比好物。
> 支持在桌面直接**右键点击小组件 ->「编辑“星元”」**独立配置单个组件视角！

### 5. 纯原生与隐私安全 (Privacy First)
- **100% 离线优先**：零网络权限请求，不上传任何云端服务器。
- **现代化技术栈**：纯原生 Swift 6、SwiftUI、SwiftData、Swift Charts 与 AppIntents 构建，内存占用极低（< 30MB），秒开无延时。
- **自由备份与导出**：支持一键导出/恢复标准 JSON 全量备份，并支持导出 CSV 明细表格。

---

## 🛠 技术架构 (Architecture)

```
Sources/
├── XingYuan/                  # 主应用 Target (macOS Application)
│   ├── App/                   # App 入口生命周期、MenuBarExtra 状态栏看板
│   ├── Engine/                # 资产核心精算模型 (AssetCalculator)、小组件数据共享快照
│   ├── Models/                # SwiftData 数据模型 (AssetItem, WishItem, FinancialRecord)
│   ├── Views/                 # 主界面、资产卡片、表格清单、检查器、趋势图表、设置
│   └── Components/            # SF Symbols 图标挑选器、状态胶囊等通用组件
│
├── XingYuanWidget/            # 原生桌面小组件 Target (WidgetKit App Extension)
│   ├── XingYuanWidgetBundle.swift   # 小组件注册入口
│   ├── XingYuanWidget.swift         # Widget 配置 (Static & AppIntent 双架构)
│   ├── XingYuanIntents.swift        # AppIntents 排序规则交互意图
│   └── WidgetViews.swift            # Small / Medium / Large 规格 SwiftUI 渲染视图
│
└── Tests/
    └── XingYuanTests/         # 算法精度与排序规则单元测试 (XCTest)
```

---

## 🚀 本地构建与运行指南 (Build & Run)

### 前置要求
- macOS 14.0 (Sonoma) 或更高版本
- Xcode 15.0+ / Command Line Tools
- [xcodegen](https://github.com/yonaskolb/XcodeGen) (推荐使用 `brew install xcodegen`)

### 快速一键构建安装
克隆本仓库并在工程根目录下执行构建脚本：

```bash
# 1. 克隆仓库
git clone https://github.com/TomTang197/XingYuan.git
cd XingYuan

# 2. 生成工程并构建打包 (包含主程序与 WidgetKit 扩展)
./scripts/build_app.sh
```

构建脚本会自动：
1. 通过 `xcodegen generate` 生成标准 `XingYuan.xcodeproj`。
2. 调用 `xcodebuild` 编译 Release 二进制并注入 Hardened Runtime 签名。
3. 自动安装至 `/Applications/XingYuan.app`。
4. 向 macOS 系统注册 `LaunchServices`、`PlugInKit` 并刷新 `chronod` 小组件守护进程。

构建完成后，可以在 `/Applications` 或通过 Alfred / Raycast / Spotlight 启动 **星元**。

---

## 🖥 如何添加桌面小组件

1. 在 Mac 桌面壁纸空白处**点击右键**，选择 **「编辑小组件...」**。
2. 在屏幕下方弹出的小组件库中找到 **「星元」**。
3. 拖拽 **Small (小号)**、**Medium (中号)** 或 **Large (大号)** 放置在桌面壁纸任意位置。
4. **自定义排序**：右键点击桌面上的小组件 -> 点击 **「编辑“星元”」**，即可自由切换 6 种排序规则！

---

## 📄 开源许可证

本项目采用 [MIT License](LICENSE) 开源许可证。欢迎提交 Issue 或 Pull Request 共同完善！
