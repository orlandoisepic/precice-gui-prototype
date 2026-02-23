//
//  ParticipantViewHelper.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 07.02.26.
//

import SwiftUI

extension ParticipantNodeView {
    
    func updateDimension(_ dim: ParticipantDimensionality?) {
        withAnimation {
            participant.dimensionality = dim
            viewModel.triggerAutoSave()
        }
    }
    
    func addPatchAtMouseLocation() {
        let center = CGPoint(
            x: viewModel.nodeRadius,
            y: viewModel.nodeRadius
        )
        let dx = lastMousePosition.x - center.x
        let dy = lastMousePosition.y - center.y
        let angle = atan2(dy, dx)
        
        viewModel.addPatch(to: participant.id, angle: angle)
    }
    
    func handleDeletion() {
            // Remove cursor from participants text fields
        NSApp.keyWindow?.makeFirstResponder(nil)
        
        viewModel.dyingParticipantIDs.insert(participant.id)
        viewModel.triggerEdgeBurnout(forNode: participant.id)
        
        withAnimation {
            isDeleting = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation {
                viewModel.deleteParticipant(id: participant.id)
            }
        }
    }
}
