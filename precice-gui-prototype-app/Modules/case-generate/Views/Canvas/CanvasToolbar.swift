    //
    //  CanvasToolbar.swift
    //  case-generate-app
    //
    //  Created by Orlando Ackermann on 07.02.26.
    //


import SwiftUI

struct CanvasToolbar: View {
    @ObservedObject var viewModel: GraphCanvasViewModel
    
    @Binding var showProjectsSidebar: Bool
    @Binding var showSaveAlert: Bool
    @Binding var showClearAlert: Bool
    @Binding var newProjectName: String
    
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                    // Generate Button
                Button(action: {
                    if viewModel.currentProjectName != nil {
                        viewModel.runSimulation()
                    } else {
                        newProjectName = "MySimulation"
                        showSaveAlert = true
                    }
                }) {
                    Label("Generate", systemImage: "play.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(themeManager.accentColor.color)
                .cornerRadius(12)
                .disabled(viewModel.generationState == .running)
                .help("Generate files")
                
                Divider().frame(height: 20)
                
                    // Save Button
                Button(action: {
                    if let current = viewModel.currentProjectName {
                        viewModel.saveProject(name: current)
                    } else {
                        newProjectName = "MySimulation"
                        showSaveAlert = true
                    }
                }) {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.bordered)
                .cornerRadius(12)
                .help("Save project")
                
                    // Clear Button
                Button(role: .destructive, action: { showClearAlert = true }) {
                    Label("Clear", systemImage: "trash")
                }
                .buttonStyle(.bordered)
                .cornerRadius(12)
                .help("Clear canvas")
                
                Divider().frame(height: 20)
                
                    // Projects Button
                Button(action: {
                    withAnimation { showProjectsSidebar.toggle() }
                }) {
                    Label {
                        HStack(spacing: 0) {
                            Text(viewModel.currentProjectName ?? "Projects")
                            Text("*")
                                .fontWeight(.bold)
                                // Only show if there are unsaved changes
                                .opacity(viewModel.hasUnsavedChanges ? 1 : 0)
                        }
                    } icon: {
                        Image(systemName: "sidebar.right")
                    }
                }
                .buttonStyle(.bordered)
                .cornerRadius(12)
                .help("Open sidebar")
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(radius: 10, y: 5)
            .padding(.bottom, 50)
        }
    }
}
