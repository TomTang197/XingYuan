import SwiftUI

public struct AssetGridView: View {
    public let assets: [AssetItem]
    @Binding public var selectedAsset: AssetItem?
    public var onEdit: (AssetItem) -> Void
    public var onMarkAsSold: (AssetItem) -> Void
    public var onMarkAsRetired: (AssetItem) -> Void
    public var onDelete: (AssetItem) -> Void
    
    private let columns = [
        GridItem(.adaptive(minimum: 180, maximum: 230), spacing: 14)
    ]
    
    public init(
        assets: [AssetItem],
        selectedAsset: Binding<AssetItem?>,
        onEdit: @escaping (AssetItem) -> Void,
        onMarkAsSold: @escaping (AssetItem) -> Void,
        onMarkAsRetired: @escaping (AssetItem) -> Void,
        onDelete: @escaping (AssetItem) -> Void
    ) {
        self.assets = assets
        self._selectedAsset = selectedAsset
        self.onEdit = onEdit
        self.onMarkAsSold = onMarkAsSold
        self.onMarkAsRetired = onMarkAsRetired
        self.onDelete = onDelete
    }
    
    public var body: some View {
        if assets.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "shippingbox")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary.opacity(0.6))
                Text("暂无资产")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text("点击右上角 + 按钮添加你的第一件物品")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.8))
            }
            .frame(maxWidth: .infinity, minHeight: 200)
            .padding(.top, 40)
        } else {
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(assets) { asset in
                    AssetCardItemView(
                        asset: asset,
                        isSelected: selectedAsset?.id == asset.id,
                        onSelect: { selectedAsset = asset },
                        onMarkAsSold: { onMarkAsSold(asset) },
                        onMarkAsRetired: { onMarkAsRetired(asset) },
                        onEdit: { onEdit(asset) },
                        onDelete: { onDelete(asset) }
                    )
                }
            }
        }
    }
}
