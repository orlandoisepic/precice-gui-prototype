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
        let name = participants.count > 0 ? "Participant\(participants.count + 1)" : "Participant"
        let newParticipant = Participant(name: name, position: location)
        participants.append(newParticipant)
        triggerAutoSave()
    }
    
    func deleteParticipant(id: UUID) {
        guard let participant = participants.first(where: { $0.id == id }) else {
            return
        }
        
            // Start death
        withAnimation(.easeIn(duration: 0.3)) {
            dyingParticipantIDs.insert(id)
            
                // Also mark connected edges as dying immediately so they fade out
            let nodeLocationNodeIds = Set(
                participant.locationNodes.map { $0.id
                })
            for edge in edges {
                if nodeLocationNodeIds
                    .contains(edge.sourceLocationNodeId) || nodeLocationNodeIds
                    .contains(edge.targetLocationNodeId) {
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
                let nodeLocationNodeIds = Set(
                    participant.locationNodes.map { $0.id
                    })
                self.edges.removeAll { edge in
                    nodeLocationNodeIds
                        .contains(
                            edge.sourceLocationNodeId
                        ) || nodeLocationNodeIds
                        .contains(edge.targetLocationNodeId)
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

            updateDynamicLocationNodeAngles(for: id)
        }
    }
    
        // MARK: - LocationNodes
    func addLocationNode(to participantId: UUID, angle: Double) {
        guard let index = participants.firstIndex(where: { $0.id == participantId }) else {
            return
        }
        let newLocationNode = LocationNode(
            id: UUID(),
            names: ["Port"],
            angle: angle,
            parentId: participantId
        )
        participants[index].locationNodes.append(newLocationNode)
        triggerAutoSave()
    }
    
    func deleteLocationNode(_ locationNode: LocationNode) {
        edges
            .removeAll {
                $0.sourceLocationNodeId == locationNode.id || $0.targetLocationNodeId == locationNode.id
            }
        if let index = participants.firstIndex(where: { $0.id == locationNode.parentId }) {
            participants[index].locationNodes
                .removeAll(where: { $0.id == locationNode.id })
        }
        triggerAutoSave()
    }
    
        // MARK: - Edge dragging
    func startDraggingConnection(
        from locationNode: LocationNode,
        at position: CGPoint
    ) {
        draggingStartLocationNode = locationNode
        draggingCurrentPos = position
    }
    
    func updateDraggingPosition(_ position: CGPoint) {
        draggingCurrentPos = position
        if let startLocationNode = draggingStartLocationNode, let parentId = findOwnerOfLocationNode(startLocationNode.id) {
            updateAnglesForNode(parentId) // Magnetic look-at
        }
        
        if let startLocationNode = draggingStartLocationNode {
            let target = findLocationNode(
                at: position,
                excluding: startLocationNode.id,
                threshold: self.locationNodeHitThreshold
            )
            
            if hoveredLocationNodeID != target?.id {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    hoveredLocationNodeID = target?.id
                }
            }
        }
    }
    
    func endDraggingConnection() {
        if let source = draggingStartLocationNode,
           let target = findLocationNode(at: draggingCurrentPos, excluding: source.id, threshold: self.locationNodeHitThreshold) {
            
            let sourceParticipant = findOwnerOfLocationNode(source.id)
            let targetParticipant = findOwnerOfLocationNode(target.id)
            // Allow new edge only if the location nodes are on the same participant
            if sourceParticipant != targetParticipant {
                addEdge(from: source, to: target)
            }

        }
        
            // Final lock
        if let source = draggingStartLocationNode, let id = findOwnerOfLocationNode(source.id) {
            updateDynamicLocationNodeAngles(for: id)
        }
        draggingStartLocationNode = nil
        
        withAnimation {
            hoveredLocationNodeID = nil
        }
    }
    
    func addEdge(from source: LocationNode, to target: LocationNode) {
        let newEdge = Edge(
            sourceLocationNodeId: source.id,
            targetLocationNodeId: target.id
        )
        edges.append(newEdge)
        
            // Update angles
        if let sOwner = findOwnerOfLocationNode(source.id) {
            updateDynamicLocationNodeAngles(for: sOwner)
        }
        if let tOwner = findOwnerOfLocationNode(target.id) {
            updateDynamicLocationNodeAngles(for: tOwner)
        }
        
        triggerAutoSave()
    }
        // Delete edge
    func triggerEdgeBurnout(forNode nodeId: UUID) {
        guard let node = participants.first(where: { $0.id == nodeId }) else {
            return
        }
        let locationNodeIds = node.locationNodes.map { $0.id }
        let connectedEdges = edges.filter {
            locationNodeIds
                .contains($0.sourceLocationNodeId) || locationNodeIds
                .contains($0.targetLocationNodeId)
        }
        for edge in connectedEdges { dyingEdgeIDs.insert(edge.id) }
    }
}
