import SwiftUI


    // Helper View for a single row
struct FileNodeRow: View {
    @ObservedObject var viewModel: GraphCanvasViewModel
    
    let node: FileNode
    let project: String
    @Binding var selection: SidebarItem?
    let indentationLevel: CGFloat
    var onPreview: (FileNode) -> Void
    
    @State private var isExpanded: Bool = false
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
               
            Button(action: {
                // Expand directories
                if node.isDirectory {
                    withAnimation(.snappy) { isExpanded.toggle() }
                } else {
                        // Select files
                    selection = .file(project: project, path: node.path)
                }
            }) {
                HStack(spacing: 6) {
                    Color.clear.frame(width: indentationLevel * 15, height: 1)
                    
                    if node.isDirectory {
                        // Folders get a > and a folder icon
                        Image(systemName: "chevron.right")
                            .font(.system(.footnote, weight: .bold))
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                            .frame(width: 13)
                        
                        Image(systemName: "folder.fill")
                            .foregroundStyle(themeManager.accentColor.color)
                            .font(.subheadline)
                    } else {
                        // Files only get a file icon
                        Image(systemName: "doc.text")
                            .foregroundStyle(isFileSelected ? .white : .secondary)
                            .font(.subheadline)
                            .padding(.leading, 22)
                    }
                    
                    // The name
                    Text(node.name)
                        .font(.callout)
                        .foregroundStyle(isFileSelected ? .white : .primary)
                        .lineLimit(1)
                    // Everyhing is as far left as possible
                    Spacer()
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(isFileSelected ? themeManager.accentColor.color.opacity(0.8) : Color.clear)
                .cornerRadius(4)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
                // Files can be opened
            .simultaneousGesture(
                TapGesture(count: 2).onEnded {
                    if !node.isDirectory {
                        onPreview(node)
                    }
                }
            )
            .contextMenu {
                    // Show in Finder
                Button {
                    let url = ProjectManager.getURL(forProject: project).appendingPathComponent(node.path)
                        // This function shows the file inside the Finder window
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                } label: {
                    Text("Show in Finder")
                    Image(systemName: "folder")
                }
                
                    // Open in default app
                Button {
                    let url = ProjectManager.getURL(forProject: project).appendingPathComponent(node.path)
                    NSWorkspace.shared.open(url)
                } label: {
                    Text("Open")
                    Image(systemName: "arrow.up.right.square")
                }
                Divider()
 
                Button(role: .destructive) {
                    viewModel.moveToTrash(project: project, path: node.path)
                } label: {
                    Text("Remove")
                    Image(systemName: "trash")
                }
            }
            .draggable(ProjectManager.getURL(forProject: project).appendingPathComponent(node.path))
            .dropDestination(for: URL.self) { items, location in
                guard node.isDirectory else { return false }
                viewModel.importFiles(items, toProject: project, subPath: node.path)
                return true
            }
            
                // 3. RECURSION
            if node.isDirectory && isExpanded, let children = node.children {
                FileTreeView(
                    viewModel: viewModel,
                    nodes: children,
                    project: project,
                    selection: $selection,
                    indentationLevel: indentationLevel + 1,
                    onPreview: onPreview
                )
            }
        }
    }
    
    private var isFileSelected: Bool {
        if node.isDirectory { return false }
        if case .file(let p, let path) = selection {
            return p == project && path == node.path
        }
        return false
    }
}
