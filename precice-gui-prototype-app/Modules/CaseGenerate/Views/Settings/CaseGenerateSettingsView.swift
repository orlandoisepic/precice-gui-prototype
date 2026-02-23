import SwiftUI

struct CaseGenerateSettingsView: View {
    
    @AppStorage("autoSaveEnabled") var autoSaveEnabled: Bool = true
    @AppStorage("showGrid") var showGrid: Bool = true
    @AppStorage("fancyAnimationsEnabled") var fancyAnimationsEnabled: Bool = true
    @EnvironmentObject var themeManager: ThemeManager
    
    
    var body: some View {
        ScrollView {
            
            VStack(alignment: .leading, spacing: 20) {
                
                    // Switches
                VStack(spacing: 15) {
                    
                        // Auto save
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Auto-save")
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                            Text("Save changes to the graph automatically while editing.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $autoSaveEnabled)
                            .labelsHidden()
                            .toggleStyle(.switch)
                    }
                    
                        //Divider().background(Color.white.opacity(0.1)) // Subtle separator
                    
                        // Background grid
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Canvas Grid")
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                            Text("Show a dot grid pattern on the background.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $showGrid)
                            .labelsHidden()
                            .toggleStyle(.switch)
                    }
                    
                    // Graph animations
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Fancy Animations")
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                            Text("Enable immersive graph effects.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $fancyAnimationsEnabled)
                            .labelsHidden()
                            .toggleStyle(.switch)
                        
                    }
                }
                // Push to the top
                Spacer()
            }
            .padding(20)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(themeManager.effectiveScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}
