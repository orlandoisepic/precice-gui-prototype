//
//  LocationNodeRing.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 07.02.26.
//
import SwiftUI

struct LocationNodeRing: View {
    @Binding var locationNodes: [LocationNode]
    let parentID: UUID
    @ObservedObject var viewModel: GraphCanvasViewModel
    
    var body: some View {
        GeometryReader { _ in
            ForEach($locationNodes) { $locationNode in
                let r = viewModel.nodeRadius
                let xPos = r + (r * cos(locationNode.angle))
                let yPos = r + (r * sin(locationNode.angle))
                
                LocationNodeView(locationNode: $locationNode, parentID: parentID, viewModel: viewModel)
                    .position(x: xPos, y: yPos)
                    .modifier(PopupAnimation(response: 0.3, damping: 0.5))
            }
        }
        .frame(width: viewModel.nodeRadius * 2, height: viewModel.nodeRadius * 2)
    }
}
