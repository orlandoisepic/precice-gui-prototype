import SwiftUI

struct DashboardCard<Content: View>: View {
    let title: String
    let description: String
    // The view to display
    let preview: Content
    var isDisabled: Bool = false
    let action: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isHovering = false
    
    init(title: String, description: String, isDisabled: Bool = false, action: @escaping () -> Void, @ViewBuilder preview: () -> Content) {
        self.title = title
        self.description = description
        self.isDisabled = isDisabled
        self.action = action
        self.preview = preview()
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                
                ZStack {
                    preview
                }
                .frame(height: 140)
                .clipped()
                .contentShape(Rectangle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2)
                        .foregroundStyle(isDisabled ? .secondary : .primary)
                    
                    Text(description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)
            }
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(themeManager.effectiveScheme == .dark ? .white.opacity(0.15) : .black.opacity(0.15), lineWidth: 1))
            // Hover effect
            .shadow(color: .black.opacity(isHovering ? 0.15 : 0.05), radius: isHovering ? 12 : 6, x: 0, y: 4)
            .scaleEffect(isHovering ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .onHover { hover in
            if !isDisabled {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovering = hover
                }
            }
        }
    }
}
