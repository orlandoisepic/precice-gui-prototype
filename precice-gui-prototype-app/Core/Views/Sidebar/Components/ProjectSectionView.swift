//
//  ProjectSectionView.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 08.02.26.
//

import SwiftUI
// Top level project folder sidebar entry
struct ProjectSectionView: View {
    let project: String
    @ObservedObject var viewModel: GraphCanvasViewModel
    
    // Bindings for state that lives in the parent
    @Binding var sidebarSelection: SidebarItem?
    @Binding var expandedProjects: Set<String>
    
    // Actions to trigger parent alerts
    var onLoad: () -> Void
    var onRename: () -> Void
    var onDelete: () -> Void
    var onPreview: (PreviewData) -> Void
    
    var body: some View {
        let isActive = (viewModel.currentProjectName == project)
        let isExpanded = expandedProjects.contains(project)
        let isDirty = (isActive && viewModel.hasUnsavedChanges)
        
        VStack(alignment: .leading, spacing: 0) {
            
            // Project row (main folder)
            Button(action: {
                sidebarSelection = .project(project)
            }) {
                ProjectRow(
                    name: project,
                    isActive: isActive,
                    hasUnsavedChanges: isDirty,
                    isExpanded: isExpanded,
                    onToggleExpand: {
                        toggleExpansion()
                    }
                )
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            // Double click to load project
            .simultaneousGesture(
                TapGesture(count: 2).onEnded {
                    onLoad()
                }
            )
            .contextMenu {
                let url = ProjectManager.getURL(forProject: project)
                // Show in Finder
                Button {
                    
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                } label: {
                    Label("Show in Finder", systemImage: "folder")
                }
                // Open file in external app
                Button {
                    NSWorkspace.shared.open(url)
                } label: {
                    Text("Open")
                    Image(systemName: "arrow.up.right.square")
                }
                
                Divider()
                
                Button("Rename") {
                    onRename()
                }
                
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Remove", systemImage: "trash")
                }
            }
            .draggable(ProjectManager.getURL(forProject: project))
            .dropDestination(for: URL.self) { items, location in
                    print(items, project)
                    viewModel.importFiles(items, toProject: project)
                    return true
            }
            
            // Tree of included / sub files
            if isExpanded {
                let fileNodes = viewModel.getProjectFileTree(project)
                
                if fileNodes.isEmpty {
                    Text("Empty folder")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .padding(.leading, 40)
                        .padding(.vertical, 4)
                } else {
                    FileTreeView(
                        viewModel: viewModel,
                        nodes: fileNodes,
                        project: project,
                        selection: $sidebarSelection,
                        indentationLevel: 1,
                        onPreview: { node in
                            let data = PreviewData(filename: node.name, project: project, path: node.path)
                            onPreview(data)
                        }
                    )
                }
            }
        }
    }
    /// Add or remove project from list of expanded projects
    private func toggleExpansion() {
        if expandedProjects.contains(project) {
            expandedProjects.remove(project)
        } else {
            expandedProjects.insert(project)
        }
    }
}
