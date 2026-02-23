
import SwiftUI

struct ProjectSidebarView: View {
    @ObservedObject var viewModel: GraphCanvasViewModel
    @Binding var isVisible: Bool
    
    @Environment(\.openWindow) var openWindow
    
    @EnvironmentObject var themeManager: ThemeManager
    
        // Selection (Using our new Enum from SidebarItem.swift)
    @State private var sidebarSelection: SidebarItem? = nil
    
        // Expanded folders
    @State private var expandedProjects: Set<String> = []
    
        // Alert States
    @State private var projectToRename: String? = nil
    @State private var newNameInput: String = ""
    @State private var showRenameAlert = false
    
    @State private var projectToLoad: String? = nil
    @State private var showLoadConfirmation = false
    
    @State private var projectToDelete: String? = nil
    @State private var showDeleteConfirmation = false
    
    @State private var showNewProjectInput = false
    @State private var showNewProjectSafety = false
    @State private var createProjectName = "New Simulation"
    
    @State private var showCollisionAlert = false
    @State private var collisionName = ""
    
    
    private func toggleExpansion(_ project: String) {
        if expandedProjects.contains(project) {
            expandedProjects.remove(project)
        } else {
            expandedProjects.insert(project)
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Push sidebar to the left
            Spacer()
                
            VStack(alignment: .leading, spacing: 0) {
                
                // Header
                SidebarHeaderView(
                    viewModel: viewModel,
                    isVisible: $isVisible,
                    onCreateProject: {
                        if viewModel.hasUnsavedChanges {
                            showNewProjectSafety = true
                        } else {
                            showNewProjectInput = true
                        }
                    }
                )
                
                Divider()
                
                    // List of projects
                ScrollView {

                    VStack(alignment: .leading, spacing: 2) {
                        if viewModel.availableProjects.isEmpty {
                            Text("No projects yet.")
                                .font(.caption)
                                .foregroundStyle(.gray)
                                .padding()
                        }
                            // The project and its components
                        ForEach(viewModel.availableProjects, id: \.self) { project in
                            ProjectSectionView(
                                project: project,
                                viewModel: viewModel,
                                sidebarSelection: $sidebarSelection,
                                expandedProjects: $expandedProjects,
                                onLoad: {
                                        // Load project
                                    if viewModel.hasUnsavedChanges {
                                        projectToLoad = project
                                        showLoadConfirmation = true
                                    } else {
                                        viewModel.loadProject(name: project)
                                    }
                                },
                                onRename: {
                                    projectToRename = project
                                    newNameInput = project
                                    showRenameAlert = true
                                },
                                onDelete: {
                                    projectToDelete = project
                                    showDeleteConfirmation = true
                                },
                                onPreview: { data in
                                    openWindow(id: "file-preview", value: data)
                                }
                            )
                        }
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, minHeight: 400, alignment: .topLeading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        sidebarSelection = nil
                    }
                }
            }
            .frame(width: 275)
            .background(.ultraThinMaterial.opacity(0.85))
            .overlay(
                Rectangle().frame(width: 1).foregroundStyle(Color.gray.opacity(0.2)),
                alignment: .leading
            )
        }
            // MARK: - Alerts for when actions on the items are triggered
        .alert("Rename Project", isPresented: $showRenameAlert) {
            TextField("New Name", text: $newNameInput)
            Button("Rename") {
                if let old = projectToRename {
                    if newNameInput == old {
                        // Alert sound if not changed
                        NSSound.beep()
                    } else if viewModel.isProjectNameAvailable(newNameInput) {
                        viewModel.renameProject(oldName: old, newName: newNameInput)
                    } else {
                        collisionName = newNameInput
                        NSSound.beep()
                        showCollisionAlert = true
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        }
        .alert("Unsaved changes", isPresented: $showLoadConfirmation) {
            Button("Discard changes and load", role: .destructive) {
                if let project = projectToLoad { viewModel.loadProject(name: project) }
            }
            Button("Cancel", role: .cancel) { projectToLoad = nil }
        } message: { Text("The current project has unsaved changes. Loading a new project will discard them.") }
            .alert("Delete Project?", isPresented: $showDeleteConfirmation) {
                Button("Remove", role: .destructive) {
                    if let project = projectToDelete { viewModel.deleteProject(name: project) }
                }
                Button("Cancel", role: .cancel) { projectToDelete = nil }
            } message: { Text("Are you sure you want to delete '\(projectToDelete ?? "this project")'?") }
            .alert("Unsaved Changes", isPresented: $showNewProjectSafety) {
                Button("Discard Changes and create new", role: .destructive) { showNewProjectInput = true }
                Button("Cancel", role: .cancel) { }
            }
            .alert("Create new project", isPresented: $showNewProjectInput) {
                TextField("Project Name", text: $createProjectName)
                Button("Create") {
                    if viewModel.isProjectNameAvailable(createProjectName) {
                        viewModel.clearCanvas()
                        viewModel.saveProject(name: createProjectName)
                        withAnimation { isVisible = false }
                        createProjectName = "New Simulation"
                    } else {
                        collisionName = createProjectName
                        showCollisionAlert = true
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
            .alert("Name already exists", isPresented: $showCollisionAlert) {
                Button("OK", role: .cancel) { }
            }
    }
}
 
