import SwiftUI
import Combine

class GraphCanvasViewModel: ObservableObject {
        // MARK: - Core Data
    @Published var participants: [Participant] = []
    @Published var edges: [Edge] = []
    
        // MARK: - State Management
    @Published var currentProjectName: String? = nil
    @Published var availableProjects: [String] = []
    @Published var hasUnsavedChanges: Bool = false
    @Published var generationState: GenerationState = .idle
    @Published var panOffset: CGPoint = .zero
        /// A set of paths to topology files that are detached from their project graphs
    @Published var detachedFiles:Set<URL> = []
    
        // MARK: - Interaction State
    @Published var draggingStartLocationNode: LocationNode? = nil
    @Published var draggingCurrentPos: CGPoint = .zero
        // Location node that we are hovering over
    @Published var hoveredLocationNodeID: UUID? = nil
    
        // MARK: - Animation State
    @Published var dyingEdgeIDs: Set<UUID> = []
    @Published var dyingParticipantIDs: Set<UUID> = []
    
        // MARK: - Constants
    let nodeRadius: CGFloat = 60
    let locationNodeHitThreshold: CGFloat = 40
    let locationNodeInnerRingRatio: CGFloat = 0.675 // The relative distance from center to inner ring (volume location nodes live there)
    
        // MARK: - File system management
        // TODO: This should maybe live somewhere under Core/
    @Published var fileSystemTrigger: UUID = UUID()
    private var workspaceMonitor: FolderMonitor? // Check for new files and update the sidebar
    
    
    init() {
        ProjectManager.ensureRootDirectoryExists()
        refreshProjectList()
        
            // TODO: This should maybe live somewhere under Core/
            // Monitor file changes in the root directory and below to accurately be represented in the sidebar
        workspaceMonitor = FolderMonitor(url: ProjectManager.rootURL)
        
        workspaceMonitor?.folderDidChange = { [weak self] in
            DispatchQueue.main.async {
                    // Trigger the UI redraw for the file trees
                self?.fileSystemTrigger = UUID()
                    // Keep the top-level project list perfectly in sync too
                self?.refreshProjectList()
            }
        }
        
            // 3. Start watching!
        workspaceMonitor?.startMonitoring()
    }
        
        // TODO: This should probably be under Core/
        // Always stop monitoring when the ViewModel is destroyed to save system resources
    deinit {
        workspaceMonitor?.stopMonitoring()
    }
    
        // Helper to reset view
    func resetView() {
        withAnimation { panOffset = .zero }
    }
    
        // Helper to mark unsaved changes
    func markDirty() {
        if !hasUnsavedChanges { hasUnsavedChanges = true }
    }
    
    func isDetached(path: URL) -> Bool {
        return detachedFiles.contains(path)
    }
    
    func markDetached(path: URL) {
        detachedFiles.insert(path)
    }
    
    func removeDetached(path: URL) {
        detachedFiles.remove(path)
    }
}
