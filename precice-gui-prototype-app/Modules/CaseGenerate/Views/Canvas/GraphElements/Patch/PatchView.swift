//
//  PatchView.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 05.02.26.
//

import SwiftUI

struct PatchView: View {
    
    @Binding var patch: Patch
    let parentID: UUID
    @ObservedObject var viewModel: GraphCanvasViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var isDeleting = false
    @State private var isHovering: Bool = false
    private var isDraggedTo: Bool {
        return viewModel.hoveredPatchID == self.patch.id
    }
    
    let radius: CGFloat = 20
    @AppStorage("fancyAnimationsEnabled") private var fancyAnimationsEnabled: Bool = true
    
    var patchColor: Color {
        if themeManager.effectiveScheme == .dark {
            return Color.orange
        } else {
                // Slighlty lighter orange in light mode
            let nsColor = NSColor.systemOrange.blended(withFraction: 0.4, of: .white) ?? NSColor.systemOrange
            return Color(nsColor: nsColor)
        }
    }
    
    var body: some View {
        // Delay of death animation
        let delay = fancyAnimationsEnabled ? 0.3 : 0.1
        ZStack {
                // Name of the patch
            TextField("Name", text: $patch.name)
                .textFieldStyle(.plain)
                .font(.caption2)
                .multilineTextAlignment(.center)
                .padding(2)
                .background(.ultraThinMaterial)
                .cornerRadius(4)
                .fixedSize()
                .offset(y: -20)
            
                // Patch shape
            Circle()
                .fill(isDeleting ? Color.white.gradient : patchColor.gradient)
                .frame(width: radius, height: radius)
                .overlay(
                    Circle()
                        .stroke(.white, lineWidth: 2)
                )
                    // Deletion effect
                .shadow(radius: (isDeleting && fancyAnimationsEnabled) ? 10 : 1)
                .opacity(isDeleting ? 0.0 : 1.0)
                .scaleEffect(isDeleting ? (fancyAnimationsEnabled ? 3.0 : 0.2) : 1.0)
                .animation(.easeOut(duration: delay), value: isDeleting)
                .gesture(
                    DragGesture(coordinateSpace: .named("CanvasSpace")) // Must match CanvasView name
                        .onChanged { value in
                                // Update patch location when draggin edge
                            if viewModel.draggingStartPatch == nil {
                                viewModel.startDraggingConnection(from: patch, at: value.location)
                            } else {
                                viewModel.updateDraggingPosition(value.location)
                            }
                        }
                        .onEnded { value in
                                // Connect to edge
                            viewModel.endDraggingConnection()
                            viewModel.triggerAutoSave()
                        }
                )
                .help(patch.name)
                .contextMenu {
                    Button(role: .destructive) {
                        NSApp.keyWindow?.makeFirstResponder(nil)
                        
                        withAnimation {
                            isDeleting = true
                        }
                            // Find edges connected to this patch and mark them for destruction
                        let connectedEdges = viewModel.edges.filter {
                            $0.sourcePatchId == patch.id || $0.targetPatchId == patch.id
                        }
                        for edge in connectedEdges {
                            viewModel.dyingEdgeIDs.insert(edge.id)
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            viewModel.deletePatch(patch)
                        }
                    } label: {
                        Label("Remove patch", systemImage: "trash")
                    }
                }
                .onChange(of: viewModel.dyingParticipantIDs) { _, dyingNodes in
                    if dyingNodes.contains(parentID) {
                        withAnimation {
                            isDeleting = true
                        }
                    }
                    
                }
                    // Slightly enlarge patch on hover or dragging connection
                .scaleEffect(isHovering || isDraggedTo ? 1.2 : 1.0)
            

        }
        .help("An interface of the participant")
        .onHover { hover in
            withAnimation(.easeInOut(duration: 0.2)) {
                    isHovering = hover
            }
        }
    }
}
