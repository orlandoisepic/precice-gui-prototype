
//
//  AddProjectButton 2.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 09.02.26.
//


//
//  AddProjectButton.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 09.02.26.
//

import SwiftUI

struct CloseSidebarButton: View {
    
    @State private var isHovering = false
    @State private var isPressed = false
    @Binding var isVisible: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
            // 3. Create Project Button ( stays on RIGHT)
        
        Button(action: closeSidebar) {
            ZStack {
                Image(systemName: "sidebar.right")
                    .fontWeight(.bold)
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(isHovering ? .primary : .secondary)
            }
                // Shared styling with CopyButton
            .frame(width: 28, height: 28)
            .background(
                Circle()
                    .fill(isHovering ? Color.primary.opacity(0.1) : Color.clear)
            )
            .scaleEffect(isPressed ? 0.8 : 1.0) // Tactile "Press" animation
        }
        .cornerRadius(14)
        .buttonStyle(.plain)
        .onHover { hover in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hover
            }
        }
        .help("Close sidebar")
        
    }
    private func closeSidebar() {
        withAnimation(.easeInOut(duration: 0.75)) { isVisible = false }
    }
}
    
