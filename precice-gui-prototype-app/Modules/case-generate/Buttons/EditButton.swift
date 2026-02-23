import SwiftUI


struct EditButton: View {
    
    @Binding var isEditable: Bool
    @State private var isHovering = false
    @State private var isPressed = false
    @EnvironmentObject var themeManager: ThemeManager
    
    private var currentBackgroundColor: Color {
        if isEditable {
                // Make accent color slightly lighter or darker depending on hovering and accent color
            if themeManager.effectiveScheme == .dark {
                return themeManager.accentColor.color.opacity(isHovering ? 0.8 : 1.0)
            }   else {
                return themeManager.accentColor.color.opacity(isHovering ? 1.0 : 0.8)
            }
                
        } else {
                // INACTIVE STATE (Locked Mode)
                // Standard button behavior: Clear, but gray when hovering.
            return isHovering ? Color.primary.opacity(0.1) : Color.clear
        }
    }
    private var currentIconColor: Color {
        if isEditable {
                // If background is Accent Color, icon should usually be White
                // for readability (assuming accent is dark/colorful).
            return Color.white
        } else {
                // Standard icon color
            return isHovering ? .primary : .secondary
        }
    }
    
    var body: some View {
        Button(action: performAction) {
            ZStack {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 12, weight: .bold))
                        // Style of the image
                    .foregroundStyle(currentIconColor)
                    .transition(.scale.combined(with: .opacity))
            }
            .frame(width: 28, height: 28)
                // Defines the "Hit Area" and Hover Background
            .background {
                Circle()
                    .fill(currentBackgroundColor)
            }
            .scaleEffect(isPressed ? 0.8 : 1.0) // The "Went Down" effect
        }
        .buttonStyle(.plain) // Removing default macOS styling
        .onHover { hover in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hover
            }
        }
        .cornerRadius(14)
        .help("Edit text")
    }
    
    private func performAction() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isPressed = true
        }
        
        if isEditable {
            isEditable = false
        } else {
            isEditable = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = false
            }
        }
    }
}
