import SwiftUI
import Combine

class ThemeManager: ObservableObject {
        // Publish the appearance mode
    @Published var appearanceMode: AppearanceMode {
        didSet {
            UserDefaults.standard
                .set(appearanceMode.rawValue, forKey: "appearanceMode")
        }
    }

    @Published var currentIconName: String {
        didSet {
            UserDefaults.standard.set(currentIconName, forKey: "appIconName")
            updateDockIcon()
        }
    }
    
    @Published var accentColor: AppAccentColor {
        didSet {
            UserDefaults.standard
                .set(accentColor.rawValue, forKey: "appAccentColor")
        }
    }
    
    init() {
        let savedTheme = UserDefaults.standard.string(
            forKey: "appearanceMode"
        ) ?? AppearanceMode.system.rawValue
        self.appearanceMode = AppearanceMode(rawValue: savedTheme) ?? .system
            // Load Icon
        self.currentIconName = UserDefaults.standard
            .string(forKey: "appIconName") ?? "Default"
            // Accent color
        let savedColor = UserDefaults.standard.string(
            forKey: "appAccentColor"
        ) ?? AppAccentColor.blue.rawValue
        self.accentColor = AppAccentColor(rawValue: savedColor) ?? .blue
        
        updateDockIcon()

            // The Safeguard: Listen for macOS system changes
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(systemThemeChanged),
            name: NSNotification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil
        )
    }
    
    @objc private func systemThemeChanged() {
            // This is the safeguard!
            // It tells every view: "Re-read my effectiveScheme property now!"
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    deinit {
        DistributedNotificationCenter.default().removeObserver(self)
    }
    
        // Update the app icon in Dock
    private func updateDockIcon() {
        if currentIconName == "Default" {
            
            if let image = NSImage(named: "AppIcon") {
                NSApplication.shared.applicationIconImage = image
            }
        } else {
                // Load custom icon
            if let image = NSImage(named: currentIconName) {
                NSApplication.shared.applicationIconImage = image
            }
        }
    }
        // Helper for the App file
    var selectedScheme: ColorScheme? {
        appearanceMode.colorScheme
    }
    
        /// Returns the current color scheme if available, otherwise the system default
        /// If the appearance mode's color scheme is not nil, return it
        /// In case appearance.colorscheme == nil (i.e., it is system-mode), then return the system default
    var effectiveScheme: ColorScheme {
        if let explicitColorScheme = appearanceMode.colorScheme {
            return explicitColorScheme
        } else {
                // Apparently macOS appearance names are aqua (light) and dark-aqua (dark)
            return NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? .dark : .light
        }
    }
}
