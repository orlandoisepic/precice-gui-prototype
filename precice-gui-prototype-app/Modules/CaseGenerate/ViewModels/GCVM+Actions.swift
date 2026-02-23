//
//  GraphCanvasViewModel+Actions.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 07.02.26.
//

import SwiftUI

extension GraphCanvasViewModel {
    
    // MARK: - Participants
    func addParticipant(at location: CGPoint) {
        let name = participants.count > 0 ? "Participant \(participants.count + 1)" : "Participant"
        let newParticipant = Participant(name: name, position: location)
        participants.append(newParticipant)
        triggerAutoSave()
    }
    
    func deleteParticipant(id: UUID) {
        guard let participant = participants.first(where: { $0.id == id }) else { return }
        
            // Start death
        withAnimation(.easeIn(duration: 0.3)) {
            dyingParticipantIDs.insert(id)
            
                // Also mark connected edges as dying immediately so they fade out
            let nodePatchIds = Set(participant.patches.map { $0.id })
            for edge in edges {
                if nodePatchIds.contains(edge.sourcePatchId) || nodePatchIds.contains(edge.targetPatchId) {
                    dyingEdgeIDs.insert(edge.id)
                }
            }
        }
        
            // Wait for the animation to finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            guard let self = self else { return }
            
                // Delete participant
            if self.participants.contains(where: { $0.id == id }) {
                
                    // Remove edges
                let nodePatchIds = Set(participant.patches.map { $0.id })
                self.edges.removeAll { edge in
                    nodePatchIds.contains(edge.sourcePatchId) || nodePatchIds.contains(edge.targetPatchId)
                }
                
                    // Remove participant
                self.participants.removeAll(where: { $0.id == id })
                self.dyingParticipantIDs.remove(id)
                
                self.triggerAutoSave()
            }
        }
    }
    
    func updateParticipantPosition(id: UUID, newPosition: CGPoint) {
        if let index = participants.firstIndex(where: { $0.id == id }) {
            participants[index].position = newPosition

            updateDynamicPatchAngles(for: id)
        }
    }
    
        // MARK: - Patches
    func addPatch(to participantId: UUID, angle: Double) {
        guard let index = participants.firstIndex(where: { $0.id == participantId }) else { return }
        let newPatch = Patch(id: UUID(), name: "Port", angle: angle, parentId: participantId)
        participants[index].patches.append(newPatch)
        triggerAutoSave()
    }
    
    func deletePatch(_ patch: Patch) {
        edges.removeAll { $0.sourcePatchId == patch.id || $0.targetPatchId == patch.id }
        if let index = participants.firstIndex(where: { $0.id == patch.parentId }) {
            participants[index].patches.removeAll(where: { $0.id == patch.id })
        }
        triggerAutoSave()
    }
    
        // MARK: - Edge dragging
    func startDraggingConnection(from patch: Patch, at position: CGPoint) {
        draggingStartPatch = patch
        draggingCurrentPos = position
    }
    
    func updateDraggingPosition(_ position: CGPoint) {
        draggingCurrentPos = position
        if let startPatch = draggingStartPatch, let parentId = findOwnerOfPatch(startPatch.id) {
            updateAnglesForNode(parentId) // Magnetic look-at
        }
        
        if let startPatch = draggingStartPatch {
            let target = findPatch(at: position, excluding: startPatch.id, threshold: self.patchHitThreshold)
            
            if hoveredPatchID != target?.id {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    hoveredPatchID = target?.id
                }
            }
        }
    }
    
    func endDraggingConnection() {
        if let source = draggingStartPatch,
           let target = findPatch(at: draggingCurrentPos, excluding: source.id, threshold: self.patchHitThreshold) {
            addEdge(from: source, to: target)
        }
        
            // Final lock
        if let source = draggingStartPatch, let id = findOwnerOfPatch(source.id) {
            updateDynamicPatchAngles(for: id)
        }
        draggingStartPatch = nil
        
        withAnimation {
            hoveredPatchID = nil
        }
    }
    
    func addEdge(from source: Patch, to target: Patch) {
        let newEdge = Edge(sourcePatchId: source.id, targetPatchId: target.id)
        edges.append(newEdge)
        
            // Update angles
        if let sOwner = findOwnerOfPatch(source.id) { updateDynamicPatchAngles(for: sOwner) }
        if let tOwner = findOwnerOfPatch(target.id) { updateDynamicPatchAngles(for: tOwner) }
        
        triggerAutoSave()
    }
    // Delete edge
    func triggerEdgeBurnout(forNode nodeId: UUID) {
        guard let node = participants.first(where: { $0.id == nodeId }) else { return }
        let patchIds = node.patches.map { $0.id }
        let connectedEdges = edges.filter { patchIds.contains($0.sourcePatchId) || patchIds.contains($0.targetPatchId) }
        for edge in connectedEdges { dyingEdgeIDs.insert(edge.id) }
    }
}
