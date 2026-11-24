English | [简体中文](README.zh-CN.md)

# ✨ XingYuan (星元)

> **Make every purchase count — longevity beats price tags.**  
> A native macOS personal asset and daily cost amortization tracker that calculates the real amortized cost of your belongings in real time, helping you build mindful spending habits and get lasting value from everything you own.

[![Platform](https://img.shields.io/badge/Platform-macOS%2014.0%2B-blue?logo=apple)](https://apple.com)
[![Swift](https://img.shields.io/badge/Swift-6.4%20%7C%20SwiftUI-orange?logo=swift)](https://swift.org)
[![Storage](https://img.shields.io/badge/Database-SwiftData-purple)]()
[![Widgets](https://img.shields.io/badge/Widgets-WidgetKit%20%2B%20AppIntents-brightgreen)]()
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## 🌟 Key Features

### 1. Real-Time Daily Cost Amortization
- **See the value of every single day**: Automatically calculates your true daily ownership cost from the purchase price and days in service ($D = \max(1, \text{Today} - \text{PurchaseDate})$):
  $$\text{DailyCost} = \frac{P_{\text{buy}} + \sum \text{Expenses} - \sum \text{Incomes}}{D}$$
- **Target Daily Cost Countdown**: Set a desired target daily cost for any item (e.g., ¥2/day), and XingYuan automatically calculates the remaining days and projected date to reach your goal.

### 2. Multi-Scenario Resale & Disposal Economics
Move beyond rigid bookkeeping when selling second-hand gear. XingYuan models 5 real-world exit scenarios:
- **Scenario 1 — Discounted Resale**: Offsets resale proceeds against your total outlay to compute true net depreciation over active service.
- **Scenario 2 — Break-Even Resale**: Resale price matches total outlay, bringing daily cost to zero ("zero-cost ownership").
- **Scenario 3 — Profitable Flip**: Resale price exceeds total outlay, producing a negative daily cost (e.g., `¥-6.00/day`) that offsets overall portfolio spend.
- **Scenario 4 — Zero-Value Disposal / Write-Off**: Accounts for the full outlay as a sunk cost upon retirement or scrap.
- **Scenario 5 — Per-Use Billing Mode**: Supports usage-based amortization for gym memberships, passes, tickets, and similar items.

### 3. Dual-Tier Native Widget System
Stay on top of your assets at a glance without even opening the main window:
- **Menu Bar Live Tracker (`MenuBarExtra`)**: Shows your active portfolio's total daily cost right in the macOS menu bar; click to open a compact Mini Dashboard with your Top 5 items and instant sort switching.
- **Native macOS Desktop Widgets (`WidgetKit` Extension)**: Built to Apple's native WidgetKit guidelines in **Small (1×1)**, **Medium (2×1)**, and **Large (2×2)** sizes — place them directly on your desktop wallpaper.

### 4. 6 Customizable Ranking Rules
Both desktop widgets and the menu bar dashboard support 6 dynamic ranking perspectives:
- **Lowest Daily Cost (Best Value)**: Your most thoroughly used, best-amortized everyday staples.
- **Highest Daily Cost (Top Spend)**: Highest daily burn items, helping you evaluate utilization.
- **Newest Purchases (Recent Additions)**: Sorted by most recent purchase date to review new gear at a glance.
- **Longest in Service (Longest Companions)**: Sorted by days in service, celebrating your longest-lasting items.
- **Highest Purchase Price (Core Assets)**: Sorted by original price descending to monitor major investments.
- **Lowest Purchase Price (Budget Gems)**: Sorted by original price ascending to highlight high-value small finds.
> **Per-Widget Configuration**: Right-click any desktop widget → **Edit "XingYuan"** (`编辑“星元”`) to configure each widget's sorting rule independently.

### 5. Native Performance & Privacy First
- **100% Offline-First**: Zero network permissions required; your data stays strictly on your Mac and is never uploaded to any server.
- **Modern Apple Stack**: Built purely with native Swift 6, SwiftUI, SwiftData, Swift Charts, and AppIntents — lightweight (< 30 MB memory footprint) with instant launch.
- **Open Backup & Export**: One-click full backup/restore in standard JSON format, plus CSV export for detailed spreadsheets.

---

## 🛠 Architecture

```text
.
├── Sources/
│   ├── XingYuan/                        # Main macOS Application Target
│   │   ├── App/                         # App lifecycle entry point & MenuBarExtra dashboard
│   │   ├── Engine/                      # Core amortization engine (AssetCalculator) & widget snapshot sharing
│   │   ├── Models/                      # SwiftData models (AssetItem, WishItem, FinancialRecord)
│   │   ├── Views/                       # Main window, asset cards, table view, inspector, trends & settings
│   │   └── Components/                  # Reusable UI components (SF Symbols picker, status badges, etc.)
│   │
│   └── XingYuanWidget/                  # Native Desktop Widget Target (WidgetKit App Extension)
│       ├── XingYuanWidgetBundle.swift   # Widget bundle registration entry point
│       ├── XingYuanWidget.swift         # Widget configuration (Static & AppIntent support)
│       ├── XingYuanIntents.swift        # AppIntents configuration for interactive sorting rules
│       └── WidgetViews.swift            # SwiftUI views for Small / Medium / Large widget families
│
└── Tests/
    └── XingYuanTests/                   # Unit tests for calculation accuracy & widget sorting (XCTest)
```

---

## 🚀 Build & Run

### Prerequisites
- macOS 14.0 (Sonoma) or later
- Xcode 15.0+ / Command Line Tools
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (recommended: `brew install xcodegen`)

### Quick One-Command Build & Install
Clone the repository and run the build script from the project root:

```bash
# 1. Clone the repository
git clone https://github.com/TomTang197/XingYuan.git
cd XingYuan

# 2. Generate the project, build, and install (main app + WidgetKit extension)
./scripts/build_app.sh
```

The build script automatically:
1. Generates a standard `XingYuan.xcodeproj` via `xcodegen generate`.
2. Builds the Release binary with `xcodebuild` and signs it with Hardened Runtime.
3. Installs the bundle to `/Applications/XingYuan.app`.
4. Registers the app and widget extension with `LaunchServices` and `PlugInKit`, and refreshes `chronod` so desktop widgets appear immediately.

Once built, launch **XingYuan (`星元`)** from `/Applications` or via Spotlight, Raycast, or Alfred.

---

## 🖥 Adding Desktop Widgets

1. **Right-click** an empty area on your Mac desktop and choose **Edit Widgets...**.
2. Find **XingYuan (`星元`)** in the Widget Gallery.
3. Drag the **Small**, **Medium**, or **Large** widget onto anywhere on your desktop.
4. **Customize Sorting**: Right-click the desktop widget → click **Edit "XingYuan"** (`编辑“星元”`) to switch between all 6 sorting rules.

---

## 📄 License

This project is open-sourced under the [MIT License](LICENSE). Issues and Pull Requests are always welcome!
