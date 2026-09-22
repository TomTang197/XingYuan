import Foundation

public struct FinancialRecord: Identifiable, Codable, Hashable {
    public var id: UUID
    public var title: String
    public var amount: Double
    public var date: Date
    public var notes: String?
    
    public init(id: UUID = UUID(), title: String, amount: Double, date: Date = Date(), notes: String? = nil) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.notes = notes
    }
}
