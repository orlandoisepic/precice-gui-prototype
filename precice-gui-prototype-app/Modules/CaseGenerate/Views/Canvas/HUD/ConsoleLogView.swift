//
//  ConsoleLogView.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 08.02.26.
//

import SwiftUI

struct ConsoleLogView: View {
    let title: String
    let log: String
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            ZStack {
                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                HStack {
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    CopyButton {
                        LogFormatter.cleanString(log)
                    }
                    
                    OpenExternalButton(
                        textContent: LogFormatter.cleanString(log),
                        tempFileName: "file-\(Date().timeIntervalSince1970).log" // unique name for the temporary file
                    )
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(.white.opacity(0.05))
            
            // Console area
            ScrollView {
                LogFormatter.formatText(log)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .textSelection(.enabled) // Allow copying
            }
            
        }
        .background(
            ZStack {Rectangle().fill(.ultraThinMaterial)}
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .cornerRadius(16)
    }
    
    private func copyToClipboard(text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents() // Clear before setting
        pasteboard.setString(text, forType: .string)
    }
    
    private func openLogExternally(content: String) {
            // Create a temporary URL
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent("file.log")
        
        do {
                // Clean the string before showing (no ANSI codes)
            let cleanLog = LogFormatter.cleanString(content)
            try cleanLog.write(to: tempFile, atomically: true, encoding: .utf8)
            
                // Open it with the default app for .log files
            NSWorkspace.shared.open(tempFile)
        } catch {
            print("Failed to create temporary log file: \(error)")
            NSSound.beep()
        }
    }
}
