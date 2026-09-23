//
//  EdgeViewHelpers.swift
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
        guard let source = findLocationNodeAndNode(id: self.edge.sourceLocationNodeId),
              let target = findLocationNodeAndNode(id: edge.targetLocationNodeId) else {
            return nil
        }
        
        var start = viewModel.getLocationNodePosition(
            participant: source.node,
            locationNode: source.locationNode
        )
        var end = viewModel.getLocationNodePosition(
            participant: target.node,
            locationNode: target.locationNode
        )
        
        let curve = calculateCurveGeometry(
            start: start,
            end: end,
            sourceNodeId: source.node.id,
            targetNodeId: target.node.id,
            currentEdgeId: edge.id
        )
        
            // Trim ONLY for surface donuts so the hole stays clear
        let trim: CGFloat = 12
        
        if source.locationNode.type == .surface {
            let dx = curve.controlPoint.x - start.x
            let dy = curve.controlPoint.y - start.y
            let len = hypot(dx, dy)
            if len > trim {
                start.x += (dx / len) * trim
                start.y += (dy / len) * trim
            }
        }
        
        if target.locationNode.type == .surface {
            let dx = curve.controlPoint.x - end.x
            let dy = curve.controlPoint.y - end.y
            let len = hypot(dx, dy)
            if len > trim {
                end.x += (dx / len) * trim
                end.y += (dy / len) * trim
            }
        }
        
        return ResolvedEdge(start: start, end: end, curve: curve)
    }
    
    private func findLocationNodeAndNode(id: UUID) -> (node: Participant, locationNode: LocationNode)? {
        for node in viewModel.participants {
            if let locationNode = node.locationNodes.first(where: { $0.id == id }) {
                return (node, locationNode)
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
            return ($0.sourceLocationNodeId == edge.sourceLocationNodeId && $0.targetLocationNodeId == edge.targetLocationNodeId) ||
            (
                $0.sourceLocationNodeId == edge.targetLocationNodeId && $0.targetLocationNodeId == edge.sourceLocationNodeId
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
