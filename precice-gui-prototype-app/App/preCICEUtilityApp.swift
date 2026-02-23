import SwiftUI

@main
struct preCICEUtilityApp: App {
        // Controls navigation between "apps"
    @StateObject private var navManager = AppNavigationManager()
    @StateObject private var themeManager = ThemeManager()
    // Global graph data to store 
    @StateObject private var graphCanvasViewModel = GraphCanvasViewModel()
    
    var body: some Scene {
        
            // Main window will always be open
        WindowGroup {
            RootView()
                .environmentObject(navManager)
                .environmentObject(themeManager)
                .environmentObject(graphCanvasViewModel)
                // Minimum size for the main window
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        
            // Separate window group to open as extra window
        WindowGroup(id: "file-preview", for: PreviewData.self) { $data in
            if let data = data {
                FilePreviewContentView(data: data)
                    .frame(minWidth: 500, minHeight: 400)
                    .backgroundStyle(.clear)
                    .containerBackground(.ultraThinMaterial, for: .window)
                    // It needs access to the graph data currently
                    .environmentObject(themeManager)
                    .environmentObject(graphCanvasViewModel)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 700, height: 500)
        .restorationBehavior(.disabled)
        
            // Settings
        Settings {
            SettingsView()
                .environmentObject(themeManager)
        }
        .restorationBehavior(.disabled)
        .windowStyle(.hiddenTitleBar)
        
            // Can be opened with openWindow(id: "simulationGame")
        WindowGroup(id: "simulationGame") {
            SimulationGameView()
                .frame(minWidth: 700,maxWidth: 1400, minHeight: 500, maxHeight: 1000)
                .environmentObject(themeManager)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .restorationBehavior(.disabled)
    }
}
