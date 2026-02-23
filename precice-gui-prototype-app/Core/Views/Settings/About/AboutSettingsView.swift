//
//  AboutSettingsView.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 06.02.26.
//
import SwiftUI

struct AboutSettingsView: View {
    // Get the current app version automatically from the Bundle
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    @EnvironmentObject var themeManager: ThemeManager
    @State private var tapCount = 0
    @State private var iconScale: CGFloat = 1.0
    
    @Environment(\.openWindow) var openWindow
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Button(action: handleSecretTap) {
                Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .shadow(radius: 10)
                    .scaleEffect(iconScale)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            VStack(spacing: 5) {
                Text("preCICE GUI")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Version \(appVersion) (Build \(buildNumber))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Divider().frame(width: 300)
            
            VStack(spacing: 8) {
                Text("Designed and Developed by")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("Orlando Ackermann")
                    .font(.headline)
            }
            
            Spacer()
            
            Text("© 2026 precice.org\nAll rights reserved.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 20)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(themeManager.effectiveScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    func handleSecretTap() {
        tapCount += 1
        
            // Enlarge on click
        withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
            iconScale = 1.2
        }
        
            // Reset bounce
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation { iconScale = 1.0 }
        }
        
            // Check Combo
        if tapCount > 3 {
            print("Starting secret game.")
            openWindow(id: "simulationGame") // Opens the separate window
            tapCount = 0
        }
    }
}
