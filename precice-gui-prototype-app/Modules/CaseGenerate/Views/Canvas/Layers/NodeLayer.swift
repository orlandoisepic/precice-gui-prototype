    //
    //  NodeLayer.swift
    //  case-generate-app
    //
    //  Created by Orlando Ackermann on 07.02.26.
    //


import SwiftUI

struct NodeLayer: View {
    @ObservedObject var viewModel: GraphCanvasViewModel

    var body: some View {
            // Show participants
        ZStack {
            ForEach($viewModel.participants) { $participant in
                DraggableNode(participant: $participant, viewModel: viewModel)
            }
        }
    }
}

    /// Internal helper view to manage individual node drag state
private struct DraggableNode: View {
    @Binding var participant: Participant
    @ObservedObject var viewModel: GraphCanvasViewModel
    
    @State private var initialPosition: CGPoint? = nil
    
    @AppStorage("fancyAnimationsEnabled") private var fancyAnimationsEnabled: Bool = true
    
    private var isDragging: Bool { initialPosition != nil }

    var body: some View {
        ParticipantNodeView(participant: $participant, viewModel: viewModel)
            .position(participant.position)
                // Slight expansion when dragging
            .scaleEffect((isDragging && fancyAnimationsEnabled) ? 1.025 : 1.0)
            .animation(.spring(duration: 0.25), value: (isDragging && fancyAnimationsEnabled))
            .gesture(
                DragGesture(coordinateSpace: .named("CanvasSpace"))
                    .onChanged { value in
                        if initialPosition == nil {
                            DispatchQueue.main.async {
                                NSApp.keyWindow?.makeFirstResponder(nil)
                            }
                            initialPosition = participant.position
                        }
                        
                        if let startPos = initialPosition {
                            let newPos = CGPoint(
                                x: startPos.x + value.translation.width,
                                y: startPos.y + value.translation.height
                            )
                            viewModel
                                .updateParticipantPosition(
                                    id: participant.id,
                                    newPosition: newPos
                                )
                        }
                    }
                    .onEnded { _ in
                        initialPosition = nil
                        viewModel.triggerAutoSave()
                    }
            )
    }
}
