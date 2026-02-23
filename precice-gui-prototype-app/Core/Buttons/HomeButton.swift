    //
    //  GlassyHomeButton.swift
    //  case-generate-app
    //
    //  Created by Orlando Ackermann on 10.02.26.
    //

import SwiftUI

struct HomeButton: View {
    @EnvironmentObject var navManager: AppNavigationManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var isHovering = false
    @State private var isPressed = false
    
    
    var body: some View {
        Button(action: performGoHome ) {
            
            ZStack {
                if themeManager.effectiveScheme == .light {
                    Image(systemName: "square.grid.3x2" )
                }
                    
                else {
                    Image(systemName: "square.grid.3x2.fill" )
                }
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(isHovering ? .primary : .secondary)
            .frame(width: 44, height: 44)
            .background(
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .opacity(isHovering ? 0.9 : 0.7)
                    Circle()
                        .strokeBorder(themeManager.effectiveScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.1), lineWidth: 0.5)
                        .blendMode(.overlay)
                }
                    .background(
                        Circle()
                            .fill(isHovering ? Color.primary.opacity(0.1) : Color.clear)
                    )
                    .scaleEffect(isPressed ? 0.8 : 1.0)
            )
            .shadow(
                color: Color.black.opacity(
                    themeManager.effectiveScheme == .dark ? 0.3 : 0.1
                ),
                radius: isHovering ? 8 : 4, x: 0, y: isHovering ? 4 : 2
            )
            .scaleEffect(isHovering ? 1.05 : 1.0)
            .contentShape(Circle())
        }
        .onHover { hover in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hover
            }
        }
        .buttonStyle(.plain)
 
        .help("Return to dashboard")
    }
    
    private func performGoHome() {
        withAnimation (.spring(response: 0.3, dampingFraction: 0.6)) {
            isPressed = true
        }
        navManager.goHome()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = false
            }
        }
        
    }
}
