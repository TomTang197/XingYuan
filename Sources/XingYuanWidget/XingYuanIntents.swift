import AppIntents
import Foundation

public struct SelectSortRuleIntent: WidgetConfigurationIntent {
    public static var title: LocalizedStringResource = "配置星元小组件"
    public static var description = IntentDescription("选择小组件展示的资产排序规则")
    
    @Parameter(title: "排序规则", default: .lowestDaily)
    public var sortRule: WidgetSortRule
    
    public init() {
        self.sortRule = .lowestDaily
    }
    
    public init(sortRule: WidgetSortRule) {
        self.sortRule = sortRule
    }
}
