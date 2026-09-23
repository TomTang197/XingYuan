import SwiftUI

public enum AssetStatus: String, CaseIterable, Codable, Identifiable {
    case active = "active"
    case retired = "retired"
    case sold = "sold"
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .active: return "服役中"
        case .retired: return "已退役"
        case .sold: return "已卖出"
        }
    }
    
    public var color: Color {
        switch self {
        case .active:
            // 统一的品牌青草绿
            return Color(red: 0.46, green: 0.82, blue: 0.12)
        case .retired:
            return Color(red: 0.60, green: 0.63, blue: 0.67)
        case .sold:
            return Color(red: 0.95, green: 0.65, blue: 0.20)
        }
    }
    
    public var iconName: String {
        switch self {
        case .active: return "bolt.circle.fill"
        case .retired: return "moon.zzz.fill"
        case .sold: return "banknote.fill"
        }
    }
}

public enum CostRule: String, CaseIterable, Codable, Identifiable {
    case byDay = "byDay"
    case byCount = "byCount"
    case custom = "custom"
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .byDay: return "按天"
        case .byCount: return "按次"
        case .custom: return "自定义"
        }
    }
    
    public var unitString: String {
        switch self {
        case .byDay: return "/天"
        case .byCount: return "/次"
        case .custom: return "/天"
        }
    }
    
    public var unitName: String {
        switch self {
        case .byDay: return "天"
        case .byCount: return "次"
        case .custom: return "天"
        }
    }
}

public enum TargetCostMode: String, CaseIterable, Codable, Identifiable {
    case none = "none"
    case byPrice = "byPrice"
    case byDate = "byDate"
    case custom = "custom"
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .none: return "不设定"
        case .byPrice: return "按价格"
        case .byDate: return "按日期"
        case .custom: return "自定义"
        }
    }
}
