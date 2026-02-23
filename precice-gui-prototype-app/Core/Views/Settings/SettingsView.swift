    //
    //  SettingsView.swift
    //  case-generate-app
    //
    //  Created by Orlando Ackermann on 06.02.26.
    //

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    var body: some View {
        TabView() {
                
            GeneralSettingsView()
                .tabItem { Label("General", systemImage: "gear") }
            
            CaseGenerateSettingsView()
            .tabItem { Label("case-generate", systemImage: "point.3.filled.connected.trianglepath.dotted") }
            
            AppearanceSettingsView()
                .tabItem { Label("Appearance", systemImage: "paintpalette") }
            
            AboutSettingsView()
                .tabItem { Label("About", systemImage: "info.circle") }
        }
            // Set the size of the window content
        .frame(width: 450, height: 400)
            // Add padding so the card doesn't touch the window edges
        .padding(12)
        // If we use themeManager.selectedScheme, then it is buggy when switching to "system"
        .preferredColorScheme(themeManager.effectiveScheme)
        
    }
}

