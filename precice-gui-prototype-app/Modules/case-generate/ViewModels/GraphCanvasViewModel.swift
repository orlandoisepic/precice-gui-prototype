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
    @Published var draggingStartPatch: Patch? = nil
    @Published var draggingCurrentPos: CGPoint = .zero
        // Patch that we are hovering over
    @Published var hoveredPatchID: UUID? = nil
    
        // MARK: - Animation State
    @Published var dyingEdgeIDs: Set<UUID> = []
    @Published var dyingParticipantIDs: Set<UUID> = []
    
        // MARK: - Constants
    let nodeRadius: CGFloat = 60
    let patchHitThreshold: CGFloat = 40
    
    init() {
        ProjectManager.ensureRootDirectoryExists()
        refreshProjectList()
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
