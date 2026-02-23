//
//  PatchRing.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 07.02.26.
//
import SwiftUI

struct PatchRing: View {
    @Binding var patches: [Patch]
    let parentID: UUID
    @ObservedObject var viewModel: GraphCanvasViewModel
    
    var body: some View {
        GeometryReader { _ in
            ForEach($patches) { $patch in
                let r = viewModel.nodeRadius
                let xPos = r + (r * cos(patch.angle))
                let yPos = r + (r * sin(patch.angle))
                
                PatchView(patch: $patch, parentID: parentID, viewModel: viewModel)
                    .position(x: xPos, y: yPos)
                    .modifier(PopupAnimation(response: 0.3, damping: 0.5))
            }
        }
        .frame(width: viewModel.nodeRadius * 2, height: viewModel.nodeRadius * 2)
    }
}
