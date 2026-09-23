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
    
        // How far inside the volume locations should sit (0.5 = halfway to the center)
    
    var body: some View {
        GeometryReader { _ in
            ForEach($locationNodes) { $locationNode in
                
                let center = viewModel.nodeRadius
                
                    //Dynamically choose the orbit distance based on the type of the location node
                let orbitRadius = locationNode.type == .surface
                ? viewModel.nodeRadius
                : (viewModel.nodeRadius * viewModel.locationNodeInnerRingRatio)
                
                    // Math: center point + (orbit distance * angle)
                let xPos = center + (orbitRadius * cos(locationNode.angle))
                let yPos = center + (orbitRadius * sin(locationNode.angle))
                
                LocationNodeView(locationNode: $locationNode, parentID: parentID, viewModel: viewModel)
                    .position(x: xPos, y: yPos)
                    .modifier(PopupAnimation(response: 0.3, damping: 0.5))
            }
        }
        .frame(width: viewModel.nodeRadius * 2, height: viewModel.nodeRadius * 2)
    }
}
