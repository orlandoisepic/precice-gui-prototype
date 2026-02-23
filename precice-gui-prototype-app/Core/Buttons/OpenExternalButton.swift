    //
    //  OpenExternalButton.swift
    //  case-generate-app
    //
    //  Created by Orlando Ackermann on 08.02.26.
    //

import SwiftUI

struct OpenExternalButton: View {
        // --- Inputs ---
        // Mode A: Open an existing file on disk
    var fileURL: URL?
    
        // Mode B: Open raw text content (creates a temp file)
    var textContent: String?
    var tempFileName: String = "file.log" // Default name for text mode
    
        // --- State ---
    @State private var isHovering = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: performOpen) {
            ZStack {
                    // The standard "External Link" icon
                Image(systemName: "arrow.up.right.square")
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
        .help("Open in external editor")
    }
    
    private func performOpen() {
            // 1. Animate the Press
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { isPressed = true }
        
            // 2. Animate Release shortly after
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { isPressed = false }
        }
        
            // 3. Smart Logic: Decide what to open
        if let url = fileURL {
                // --- Mode A: Existing File ---
                // Just ask the Workspace to open the URL directly
            NSWorkspace.shared.open(url)
        }
        else if let content = textContent {
                // --- Mode B: Raw Text ---
                // Write it to a temp file, then open that
            openTempString(content)
        }
    }
    
    private func openTempString(_ text: String) {
        let tempDir = FileManager.default.temporaryDirectory
            // We append the custom filename here (e.g., "execution.log")
        let tempFile = tempDir.appendingPathComponent(tempFileName)
        
        do {
            try text.write(to: tempFile, atomically: true, encoding: .utf8)
            NSWorkspace.shared.open(tempFile)
        } catch {
            print("Failed to open temp file: \(error)")
            NSSound.beep()
        }
    }
}
