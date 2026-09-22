import SwiftUI

public struct SFIconPicker: View {
    @Binding public var selectedIcon: String
    @Environment(\.dismiss) private var dismiss
    
    private let iconCategories: [(name: String, icons: [String])] = [
        ("常用设备", [
            "laptopcomputer", "desktopcomputer", "ipad", "iphone",
            "applewatch", "airpodspro", "headphones", "camera.fill",
            "gamecontroller.fill", "tv.fill", "display", "server.rack"
        ]),
        ("生活与出行", [
            "car.fill", "bicycle", "tram.fill", "airplane",
            "house.fill", "bed.double.fill", "chair.lounge.fill", "sofa.fill",
            "refrigerator.fill", "washer.fill", "microwave.fill", "fanblades.fill"
        ]),
        ("日常杂物", [
            "shippingbox.fill", "cube.box.fill", "bag.fill", "cart.fill",
            "eyeglasses", "tshirt.fill", "shoe.fill", "watchface.applewatch.case",
            "wrench.and.screwdriver.fill", "powerplug.fill", "externaldrive.fill", "keyboard.fill"
        ]),
        ("文娱与兴趣", [
            "book.fill", "guitars.fill", "pianokeys.fill", "paintbrush.fill",
            "figure.run", "dumbbell.fill", "tennisball.fill", "cup.and.saucer.fill"
        ])
    ]
    
    public init(selectedIcon: Binding<String>) {
        self._selectedIcon = selectedIcon
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("选择物品图标")
                    .font(.headline)
                Spacer()
                Button("完成") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(iconCategories, id: \.name) { cat in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(cat.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                                ForEach(cat.icons, id: \.self) { icon in
                                    Button {
                                        selectedIcon = icon
                                        dismiss()
                                    } label: {
                                        VStack {
                                            Image(systemName: icon)
                                                .font(.system(size: 22))
                                                .frame(width: 44, height: 44)
                                                .foregroundColor(selectedIcon == icon ? .white : .primary)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(selectedIcon == icon ? Color.accentColor : Color(nsColor: .controlBackgroundColor))
                                                )
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .frame(width: 360, height: 440)
    }
}
