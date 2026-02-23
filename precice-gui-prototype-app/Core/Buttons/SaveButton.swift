import SwiftUI


struct SaveButton: View {
    
    let action: () -> Void
    @Binding var isDirty: Bool
    @State private var isHovering = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: performAction) {
            ZStack {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(
                        (isHovering && isDirty) ? .primary : .secondary
                    )
                    .transition(.scale.combined(with: .opacity))
            }
            .frame(width: 28, height: 28)
                // Defines the "Hit Area" and Hover Background
            .background {
                Circle()
                    .fill(isHovering ? Color.primary.opacity(0.1) : Color.clear)
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
        // Save with cmd + s
        .keyboardShortcut("s", modifiers: .command)
        .disabled(!isDirty)
        .help("Copy to clipboard")
    }
    
    private func performAction() {
        withAnimation(.spring(response:0.3, dampingFraction: 0.6)) {
            isPressed = true
        }
        
        action()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response:0.3, dampingFraction: 0.6)) {
                isPressed = false
            }
        }
    }
}
