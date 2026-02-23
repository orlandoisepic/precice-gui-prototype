    //
    //  CopyButton.swift
    //  case-generate-app
    //
    //  Created by Orlando Ackermann on 08.02.26.
    //

import SwiftUI

struct CopyButton: View {
        // Function to get the clean text
    let textProvider: () -> String
    @State private var isCopied = false
    @State private var isHovering = false
    @State private var isPressed = false // Custom state for the "click" animation

    var body: some View {
        Button(action: performCopy) {
            ZStack {
                    // State 1: The Success Checkmark
                if isCopied {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.green)
                        .transition(.scale.combined(with: .opacity))
                }
                    // State 2: The Copy Icon
                else {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(isHovering ? .primary : .secondary)
                        .transition(.scale.combined(with: .opacity))
                }
            }
                // Defines the "Hit Area" and Hover Background
            .frame(width: 28, height: 28)
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
        .help("Copy to clipboard")
    }
    
    private func performCopy() {
            // 1. "Button Down" Animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isPressed = true
        }
        
            // 2. Perform the Copy
        let cleanText = textProvider()
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(cleanText, forType: .string)
        
            // 3. "Button Up" & Show Checkmark
            // Delay slightly so the user sees the "press"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = false
                isCopied = true
            }
        }
        
            // 4. Reset back to Copy Icon after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isCopied = false
            }
        }
    }
}
