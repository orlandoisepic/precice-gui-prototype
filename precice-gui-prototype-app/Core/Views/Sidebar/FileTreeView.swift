import SwiftUI

struct FileTreeView: View {
    
    @ObservedObject var viewModel: GraphCanvasViewModel
    let nodes: [FileNode]
    let project: String
    @Binding var selection: SidebarItem?
    let indentationLevel: CGFloat
    var onPreview: (FileNode) -> Void
    
    var body: some View {
        ForEach(nodes) { node in
            FileNodeRow(
                viewModel: viewModel,
                node: node,
                project: project,
                selection: $selection,
                indentationLevel: indentationLevel,
                onPreview: onPreview // Pass it doww
            )
        }
    }
}

 
