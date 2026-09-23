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
            if let startLocationNode = viewModel.draggingStartLocationNode,
               let startNode = viewModel.participants.first(where: { $0.id == startLocationNode.parentId }),
               let liveLocationNode = startNode.locationNodes.first(where: { $0.id == startLocationNode.id }) {
                
                let rawStartPos = viewModel.getLocationNodePosition(
                    participant: startNode,
                    locationNode: liveLocationNode
                )
                
                Path { path in
                    let trimRadius: CGFloat = 12
                    let dx = viewModel.draggingCurrentPos.x - rawStartPos.x
                    let dy = viewModel.draggingCurrentPos.y - rawStartPos.y
                    let dist = hypot(dx, dy)
                    
                    let trimmedStartPos: CGPoint
                    if dist > trimRadius {
                        trimmedStartPos = CGPoint(
                            x: rawStartPos.x + (dx / dist) * trimRadius,
                            y: rawStartPos.y + (dy / dist) * trimRadius
                        )
                    } else {
                        trimmedStartPos = rawStartPos
                    }
                    
                    path.move(to: trimmedStartPos)
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
