//
//  to.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 07.02.26.
//
import SwiftUI


struct CurveGeometry {
    let controlPoint: CGPoint;
    let perpVector: CGVector
}


extension EdgeView {
    
        // Helper struct to bundle the calculated data
    struct ResolvedEdge {
        let start: CGPoint
        let end: CGPoint
        let curve: CurveGeometry
    }
    
    var resolvedEdgeData: ResolvedEdge? {
        guard let source = findPatchAndNode(id: self.edge.sourcePatchId),
              let target = findPatchAndNode(id: edge.targetPatchId) else {
            return nil
        }
        
        let start = viewModel.getPatchPosition(
            participant: source.node,
            patch: source.patch
        )
        let end = viewModel.getPatchPosition(
            participant: target.node,
            patch: target.patch
        )
        
        let curve = calculateCurveGeometry(
            start: start,
            end: end,
            sourceNodeId: source.node.id,
            targetNodeId: target.node.id,
            currentEdgeId: edge.id
        )
        
        return ResolvedEdge(start: start, end: end, curve: curve)
    }
    
    private func findPatchAndNode(id: UUID) -> (node: Participant, patch: Patch)? {
        for node in viewModel.participants {
            if let patch = node.patches.first(where: { $0.id == id }) {
                return (node, patch)
            }
        }
        return nil
    }
    
        // MARK: - Geometry Calculation
    /// Calculate the direction of the edge.
    /// This creates the "correct" bending of the edge, regardless of its actual direction.
    private func calculateCurveGeometry(start: CGPoint, end: CGPoint, sourceNodeId: UUID, targetNodeId: UUID, currentEdgeId: UUID) -> CurveGeometry {
        
            // Get "direction" of edge
        let isCanonical = sourceNodeId.uuidString < targetNodeId.uuidString
        let nodeA_ID = isCanonical ? sourceNodeId : targetNodeId
        let nodeB_ID = isCanonical ? targetNodeId : sourceNodeId
        
        var posA = start; var posB = end
        
        if let nodeA = viewModel.participants.first(
            where: { $0.id == nodeA_ID
            }),
           let nodeB = viewModel.participants.first(
            where: { $0.id == nodeB_ID
            }) {
            posA = nodeA.position; posB = nodeB.position
        }
        
        let midX = (start.x + end.x) / 2
        let midY = (start.y + end.y) / 2
        
        let siblings = viewModel.edges.filter {
            return ($0.sourcePatchId == edge.sourcePatchId && $0.targetPatchId == edge.targetPatchId) ||
            (
                $0.sourcePatchId == edge.targetPatchId && $0.targetPatchId == edge.sourcePatchId
            )
        }.sorted(by: { $0.id.uuidString < $1.id.uuidString })
        
        let dx = posB.x - posA.x
        let dy = posB.y - posA.y
        let len = sqrt(dx*dx + dy*dy)
        let safeLen = len > 0 ? len : 1
        let perpX = -dy / safeLen
        let perpY = dx / safeLen
        
        var offsetMagnitude: CGFloat = 0
        if siblings.count > 1, let index = siblings.firstIndex(
            where: { $0.id == currentEdgeId
            }) {
            let shiftIndex = Double(index) - Double(siblings.count - 1) / 2.0
            let distance = hypot(end.x - start.x, end.y - start.y)
            offsetMagnitude = CGFloat(shiftIndex) * (distance * 0.2)
        }
        
        let controlPoint = CGPoint(
            x: midX + (perpX * offsetMagnitude),
            y: midY + (perpY * offsetMagnitude)
        )
        
        let finalDirX = perpX * (
            offsetMagnitude == 0 ? 1.0 : (offsetMagnitude > 0 ? 1.0 : -1.0)
        )
        let finalDirY = perpY * (
            offsetMagnitude == 0 ? 1.0 : (offsetMagnitude > 0 ? 1.0 : -1.0)
        )
        
        return CurveGeometry(
            controlPoint: controlPoint,
            perpVector: CGVector(dx: finalDirX, dy: finalDirY)
        )
    }
}
