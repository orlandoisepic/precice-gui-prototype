    //
    //  ThemeOptionButton.swift
    //  case-generate-app
    //
    //  Created by Orlando Ackermann on 06.02.26.
    //
import SwiftUI

struct ThemeOptionButton: View {
    let mode: AppearanceMode
    let current: AppearanceMode
    let icon: String
    let color: Color
    let action: () -> Void
    
    var isSelected: Bool { current == mode }
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.5)) {
                action()
            }
        }) {
            
            VStack(spacing: 8) {
                    // The Preview Card
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(mode == .dark ? .white : .gray)
                }
                .frame(height: 60)
                
                    // The Label
                Text(mode.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundStyle(isSelected ? .blue : .secondary)
                
                    // Selection Indicator (Blue Dot)
                if isSelected {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 4, height: 4)
                } else {
                    Circle().fill(Color.clear).frame(width: 4, height: 4)
                }
            }
            .contentShape(Rectangle()) // Make whole area clickable
        }
        .buttonStyle(.plain) // Removes default button look
        .frame(width: 80)
            // Add a blue ring if selected
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue :
                            (themeManager.effectiveScheme == .dark ? .white.opacity(0.15) : .black.opacity(0.15) ),
                        lineWidth: isSelected ? 2 : 1)
                .padding(-5) // Offset ring slightly outside
        )
        .animation(.snappy, value: current)
    }
}
