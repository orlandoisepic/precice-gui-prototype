//
//  GeneralSettingsView.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 10.02.26.
//


import SwiftUI

struct GeneralSettingsView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            // TODO Add some general settings
            EmptyView()
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
