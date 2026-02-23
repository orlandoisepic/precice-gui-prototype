//
//  WarningMessage.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 09.02.26.
//
import SwiftUI

struct WarningMessage: View {
    @Binding var isEditable: Bool
    @Binding var warningShown: Bool
    var data: PreviewData
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var graphCanvasViewModel: GraphCanvasViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 12) {
            
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .symbolEffect(.pulse)
                .foregroundStyle(.orange.opacity(0.8))
            Text("Edit file manually?")
                .font(.body.weight(.semibold))
                // Information on how to make the graph the "truth" again (this does not sound ideal yet)
            Text("Click 'Generate' from the graph canvas to discard edits.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            HStack(spacing: 8) {
                Button(action: cancel) {
                    Text("Cancel")
                        .padding(.horizontal, 5)
                }
                .cornerRadius(12)
                .buttonStyle(.borderedProminent)
                .tint(themeManager.accentColor.color)
                
                Button(action: makeEditable) {
                    Text("Proceed")
                        .padding(.horizontal, 5)
                }
                .cornerRadius(12)
                .buttonStyle(.bordered)
            }
            
        }
        .padding(30)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 10)
    }
    private func cancel () {
        withAnimation(.easeOut(duration: 0.2)) {
            dismiss()
        }
        
    }
    
    private func makeEditable () {
        withAnimation(.easeOut(duration: 0.2)) {
            isEditable = true
            warningShown = true
            // Editing -> Topology is detached and not represented by the graph
            graphCanvasViewModel.markDetached(path: ProjectManager.getFileURL(forProject: data.project, with: data.path))
            print("Marked detached: \(ProjectManager.getFileURL(forProject: data.project, with: data.path))")
            dismiss()
        }
    }
}
