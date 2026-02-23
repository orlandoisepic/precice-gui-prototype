import SwiftUI

struct CanvasView: View {
        
    @EnvironmentObject var viewModel: GraphCanvasViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var canvasMousePosition: CGPoint = .zero
    @State private var dragOffset: CGSize = .zero
    
        // Indicators for the sidebar
    @State private var showProjectsSidebar = false
    @State private var showSaveAlert = false
    @State private var newProjectName = ""
    @State private var showClearAlert = false
    
    var body: some View {
        ZStack {
            BackgroundLayer(
                dragOffset: $dragOffset,
                canvasMousePosition: $canvasMousePosition
                )
             // Nodes and edegs
            ZStack {
                ConnectionLayer(viewModel: viewModel)
                NodeLayer(viewModel: viewModel)
            }
            .coordinateSpace(name: "CanvasSpace")
            .offset(
                x: viewModel.panOffset.x + dragOffset.width,
                y: viewModel.panOffset.y + dragOffset.height
            )
            .animation(.interactiveSpring(), value: dragOffset)
            .animation(.easeInOut, value: viewModel.panOffset)
            // Bottom toolbar
            CanvasToolbar(
                viewModel: viewModel,
                showProjectsSidebar: $showProjectsSidebar,
                showSaveAlert: $showSaveAlert,
                showClearAlert: $showClearAlert,
                newProjectName: $newProjectName
            )
            
                // Sidebar
            if showProjectsSidebar {
                ProjectSidebarView(
                    viewModel: viewModel,
                    isVisible: $showProjectsSidebar,
                )
                .transition(.move(edge: .trailing))
            }
            // Indicator for generation running or not
            ActivityHUDView(state: $viewModel.generationState)
            
        } // End of ZStack
        //.coordinateSpace(name: "CanvasSpace")
        .frame(minWidth: 900, minHeight: 600)
            // Alerts for intercation with bottom toolbar
        .alert("New project", isPresented: $showSaveAlert) {
            TextField("Project name", text: $newProjectName)
            Button("Save") {
                viewModel.saveProject(name: newProjectName)
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Clear project?", isPresented: $showClearAlert) {
            Button("Clear", role: .destructive) { viewModel.clearCanvas() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Unsaved changes will be lost.")
        }
        .preferredColorScheme(themeManager.selectedScheme)
    }
}
