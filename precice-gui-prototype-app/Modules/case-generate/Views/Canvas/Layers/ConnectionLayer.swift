    //
    //  ConnectionLayer.swift
    //  case-generate-app
    //
    //  Created by Orlando Ackermann on 07.02.26.
    //


import SwiftUI
    // A layer to connect nodes on
struct ConnectionLayer: View {
    @ObservedObject var viewModel: GraphCanvasViewModel

    var body: some View {
        ZStack {
                // Show edges that exist already
            ForEach($viewModel.edges) { $edge in
                EdgeView(edge: $edge, viewModel: viewModel)
            }
            
                // The line when dragging (not yet existing edges)
            if let startPatch = viewModel.draggingStartPatch,
               let startNode = viewModel.participants.first(
                where: { $0.id == startPatch.parentId
                }),
               let livePatch = startNode.patches.first(
                where: { $0.id == startPatch.id
                }) {
                
                let startPos = viewModel.getPatchPosition(
                    participant: startNode,
                    patch: livePatch
                )
                
                Path { path in
                    path.move(to: startPos)
                    path.addLine(to: viewModel.draggingCurrentPos)
                }
                .stroke(
                    Color.gray,
                    style: StrokeStyle(lineWidth: 2, dash: [5, 5])
                )
            }
        }
    }
}
