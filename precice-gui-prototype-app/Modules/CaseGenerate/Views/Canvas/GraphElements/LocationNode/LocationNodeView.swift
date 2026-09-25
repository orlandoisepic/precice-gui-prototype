    //
    //  LocationNodeView.swift
    //  case-generate-app
    //
    //  Created by Orlando Ackermann on 05.02.26.
    //

import SwiftUI

struct LocationNodeView: View {
    
    @Binding var locationNode: LocationNode
    let parentID: UUID
    @ObservedObject var viewModel: GraphCanvasViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var isDeleting = false
    @State private var isHovering: Bool = false
    private var isDraggedTo: Bool {
        return viewModel.hoveredLocationNodeID == self.locationNode.id
    }
    
    @AppStorage("fancyAnimationsEnabled") private var fancyAnimationsEnabled: Bool = true
    
    @State private var localText: String = ""
    @FocusState private var isFocused: Bool
        
    var locationNodeColor: Color {
        if themeManager.effectiveScheme == .dark {
            return Color.orange
        } else {
                // Slighlty lighter orange in light mode
            let nsColor = NSColor.systemOrange.blended(
                withFraction: 0.4,
                of: .white
            ) ?? NSColor.systemOrange
            return Color(nsColor: nsColor)
        }
    }
    
        // MARK: - Dynamic Shape
    @ViewBuilder
    var nodeShape: some View {
        let lineWidth: CGFloat = 2 // Width of the white outline
        let widthFactor = 0.8 // Reduce width of outline in surface view
        let donutWidth = 0.6 // Width of the donut w.r.t. location node radius
        let insetFactor: CGFloat = 12 / 24
        if locationNode.type == .surface {
                // Surface view
                // A donut with location node color, but white outline
            Circle()
                .strokeBorder(
                    isDeleting ? Color.white.gradient : locationNodeColor.gradient,
                    lineWidth: viewModel.locationNodeRadius * donutWidth
                )
                // The outer white border
                .overlay(
                    Circle()
                        .strokeBorder(
                            .white,
                            lineWidth: widthFactor*lineWidth
                        ) // Slightly smaller outline
                )
                // The inner white border
                .overlay(
                    Circle()
                        .inset(by: viewModel.locationNodeRadius * insetFactor)
                        .strokeBorder(.white, lineWidth: widthFactor*lineWidth)
                )
                .contentShape(Circle()) // To make the interior clickable
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
        } else {
                // Volume view
            VolumeNodeView(nodeColor: locationNodeColor, size: viewModel.locationNodeRadius * 2, lineWidth: lineWidth)
        }
            
    }
    
    var body: some View {
            // Delay of death animation
        let delay = fancyAnimationsEnabled ? 0.3 : 0.1
        // For radius 25/2 -> 1.2. For radius 50/2 -> 1.1
        let hoverScale = 1.3 - (viewModel.locationNodeRadius / 125)
        ZStack {
            TextField("Names", text: $localText)
                .focused($isFocused)
                .textFieldStyle(.plain)
                .font(.caption2)
                .multilineTextAlignment(.center)
                .padding(2)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
                .fixedSize()
                .offset(y: -(viewModel.locationNodeRadius + 10)) // Radius 25/2 -> -22.5, Radius 50/2 -> -35
                .onAppear {
                        // Set initial collapsed state when the node loads
                    updateCollapsedText()
                }
                .onChange(of: isFocused) { _, focused in
                    if focused {
                            // 1. Entering edit mode: Expand to the full comma list
                        localText = locationNode.names.joined(separator: ", ")
                    } else {
                            // 2. Exiting edit mode: Parse, save, and collapse
                        let parsed = localText.components(separatedBy: ",")
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            .filter { !$0.isEmpty }
                        
                        locationNode.names = parsed.isEmpty ? ["Port"] : parsed
                        viewModel.triggerAutoSave()
                        
                            // Shrink back down to the "+n" display
                        updateCollapsedText()
                    }
                }
                .onSubmit {
                        // Hitting "Enter" drops focus, triggering the onChange block above
                    isFocused = false
                }
            
                // Location node shape (dynamically rendered)
            nodeShape
                .frame(width: viewModel.locationNodeRadius * 2, height: viewModel.locationNodeRadius * 2)
                // Deletion effect
                .shadow(radius: (isDeleting && fancyAnimationsEnabled) ? 10 : 1)
                .opacity(isDeleting ? 0.0 : 1.0)
                .scaleEffect(
                    isDeleting ? (fancyAnimationsEnabled ? 3.0 : 0.2) : 1.0
                )
                .animation(.easeOut(duration: delay), value: isDeleting)
                .gesture(
                    DragGesture(
                        minimumDistance: 0,
                        coordinateSpace: .named("CanvasSpace")
                    ) // Must match CanvasView name
                        .onChanged { value in
                                // Update location node location when dragging edge
                            if viewModel.draggingStartLocationNode == nil {
                                viewModel
                                    .startDraggingConnection(
                                        from: locationNode,
                                        at: value.location
                                    )
                            } else {
                                withAnimation(
                                    .interactiveSpring(
                                        response: viewModel.nodeMovementResponse,
                                        dampingFraction: viewModel.nodeMovementDamping
                                    )
                                ) {
                                    viewModel
                                        .updateDraggingPosition(value.location)
                                }
                            }
                        }
                        .onEnded { value in
                                // Connect to edge
                            viewModel.endDraggingConnection()
                            viewModel.triggerAutoSave()
                        }
                )
                .help(locationNode.names.joined(separator: ", "))
                .contextMenu {
                    
                        // Quick toggle to switch types
                    Button(
                        locationNode.type == .surface ? "Change type to volume" : "Change type to surface"
                    ) {
                        locationNode.type = (
                            locationNode.type == .surface
                        ) ? .volume : .surface
                        viewModel.triggerAutoSave()
                    }
                    
                    Divider()
                        // Delete node
                    Button("Remove location", role: .destructive) {
                        NSApp.keyWindow?.makeFirstResponder(nil)
                        
                        withAnimation {
                            isDeleting = true
                        }
                            // Find edges connected to this location node and mark them for destruction
                        let connectedEdges = viewModel.edges.filter {
                            $0.sourceLocationNodeId == locationNode.id || $0.targetLocationNodeId == locationNode.id
                        }
                        for edge in connectedEdges {
                            viewModel.dyingEdgeIDs.insert(edge.id)
                        }
                        
                        DispatchQueue.main
                            .asyncAfter(deadline: .now() + delay) {
                                viewModel.deleteLocationNode(locationNode)
                            }
                    }
                }
                .onChange(of: viewModel.dyingParticipantIDs) { _, dyingNodes in
                    if dyingNodes.contains(parentID) {
                        withAnimation {
                            isDeleting = true
                        }
                    }
                    
                }
                // Slightly enlarge location node on hover or dragging connection
                .scaleEffect(isHovering || isDraggedTo ? hoverScale : 1.0)
            
        }
        .help("An interface of the participant")
        .onHover { hover in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hover
            }
        }
    }
    
        // Format the content inside the text field as "First-name +n" when there are n+1 entries
    private func updateCollapsedText() {
        guard let first = locationNode.names.first, !first.isEmpty else {
            localText = "Port"
            return
        }
        localText = locationNode.names.count > 1 ? "\(first) +\(locationNode.names.count - 1)" : first
    }
    

}
