import SwiftUI

public struct StatusBadge: View {
    public let status: AssetStatus
    
    public init(_ status: AssetStatus) {
        self.status = status
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(status.color)
                .frame(width: 6, height: 6)
            
            Text(status.title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(Color(nsColor: .quaternaryLabelColor).opacity(0.6))
        )
    }
}
