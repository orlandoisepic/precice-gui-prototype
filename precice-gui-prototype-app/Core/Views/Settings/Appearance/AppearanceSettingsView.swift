import SwiftUI

struct AppearanceSettingsView: View {
        // We need to bind to the manager to change the icon
    @EnvironmentObject var themeManager: ThemeManager
    
    let colorColumns = [
        GridItem(.adaptive(minimum: 40))
    ]
    
    var body: some View {
        ScrollView{
            
            VStack(alignment: .leading, spacing: 20) {
                // Appearance mode
                Text("Choose your style")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 15) {
                    
                        // Default
                    ThemeOptionButton(
                        mode: .system,
                        current: themeManager.appearanceMode,
                        icon: "display",
                        color: .gray.opacity(0.2)
                    ) { themeManager.appearanceMode = .system }
                    
                        // Light mode field
                    ThemeOptionButton(
                        mode: .light,
                        current: themeManager.appearanceMode,
                        icon: "sun.max.fill",
                        color: .white
                    ) { themeManager.appearanceMode = .light }
                    
                        // Dark mode field
                    ThemeOptionButton(
                        mode: .dark,
                        current: themeManager.appearanceMode,
                        icon: "moon.fill",
                        color: .black.opacity(0.8)
                    ) { themeManager.appearanceMode = .dark }
                }
                
                Divider().background(Color.white.opacity(0.2))
                // Accent color
                Text("Choose accent color")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                LazyVGrid(columns: colorColumns, spacing: 15) {
                    ForEach(AppAccentColor.allCases, id: \.self) { colorOption in
                        Circle()
                            .fill(colorOption.color.gradient)
                            .frame(width: 34, height: 34)
                            .shadow(color: colorOption.color.opacity(0.4), radius: 3, y: 2)
                            // The Selection Ring
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.white, lineWidth: themeManager.accentColor == colorOption ? 2 : 0)
                                    .padding(-2)
                            )
                            .overlay(
                                Circle()
                                    .strokeBorder(themeManager.accentColor == colorOption ? colorOption.color : .clear, lineWidth: 2)
                                    .padding(-4)
                            )
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    themeManager.accentColor = colorOption
                                }
                            }
                            .help(colorOption.label)
                    }
                }
                .padding(.vertical, 5)
                
                Divider().background(Color.white.opacity(0.2))
                // Icon
                Text("Choose App Icon")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 15) {
                        // Default
                    IconOptionButton(
                        imageName: "AppIcon",
                        assetName: "Default",
                        selectedName: themeManager.currentIconName
                    ) { themeManager.currentIconName = "Default" }
                    
                        // Dark icon
                    IconOptionButton(
                        imageName: "AppIcon-Dark",
                        assetName: "AppIcon-Dark",
                        selectedName: themeManager.currentIconName
                    ) { themeManager.currentIconName = "AppIcon-Dark" }
                    
                        // Light icon
                    IconOptionButton(
                        imageName: "AppIcon-Light",
                        assetName: "AppIcon-Light",
                        selectedName: themeManager.currentIconName
                    ) { themeManager.currentIconName = "AppIcon-Light" }
                }
                
                Spacer()
            }
            .padding(20)
        }
        //.padding(25)
        .background(.ultraThinMaterial.opacity(0.8))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(themeManager.effectiveScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

