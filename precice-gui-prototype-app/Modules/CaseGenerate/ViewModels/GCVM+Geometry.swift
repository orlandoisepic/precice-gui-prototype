//
//  GraphCanvasViewModel+Geometry.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 07.02.26.
//

import SwiftUI

extension GraphCanvasViewModel {
    
        // MARK: - Position Helpers
    func getPatchPosition(participant: Participant, patch: Patch) -> CGPoint {
        let x = participant.position.x + (nodeRadius * cos(patch.angle))
        let y = participant.position.y + (nodeRadius * sin(patch.angle))
        return CGPoint(x: x, y: y)
    }
    
    func findPatch(at location: CGPoint, excluding sourcePatchId: UUID, threshold: CGFloat = 30) -> Patch? {
        for participant in participants {
            for patch in participant.patches {
                if patch.id == sourcePatchId { continue }
                let patchPos = getPatchPosition(participant: participant, patch: patch)
                if hypot(patchPos.x - location.x, patchPos.y - location.y) < threshold {
                    return patch
                }
            }
        }
        return nil
    }
    
    func findOwnerOfPatch(_ patchId: UUID) -> UUID? {
        for p in participants {
            if p.patches.contains(where: { $0.id == patchId }) { return p.id }
        }
        return nil
    }
    
        // MARK: - "Magnetic" logic for patches when draggin edges
    
    func updateDynamicPatchAngles(for centerNodeId: UUID) {
        updateAnglesForNode(centerNodeId)
        
            // Find connected neighbors
        let connectedEdges = edges.filter {
            let s = findOwnerOfPatch($0.sourcePatchId)
            let t = findOwnerOfPatch($0.targetPatchId)
            return s == centerNodeId || t == centerNodeId
        }
        
        var neighborIds = Set<UUID>()
        for edge in connectedEdges {
            if let s = findOwnerOfPatch(edge.sourcePatchId), s != centerNodeId { neighborIds.insert(s) }
            if let t = findOwnerOfPatch(edge.targetPatchId), t != centerNodeId { neighborIds.insert(t) }
        }
        
        for neighborId in neighborIds { updateAnglesForNode(neighborId) }
    }
    
    // Update the angles of patches on a participant node
    func updateAnglesForNode(_ nodeId: UUID) {
        guard let index = participants.firstIndex(where: { $0.id == nodeId }) else { return }
        let patches = participants[index].patches
        if patches.isEmpty { return }
        
            // Calculate ideal angles
        struct PatchAngleInfo { let index: Int; var angle: Double }
        var angleInfos: [PatchAngleInfo] = []
        
        for i in 0..<patches.count {
            let ideal = calculateBestAngleForPatch(patches[i], on: participants[index]) ?? patches[i].angle
            angleInfos.append(PatchAngleInfo(index: i, angle: ideal))
        }
        
        angleInfos.sort { $0.angle < $1.angle }
        
            // A minimum spacing to avoid too close patches
        // TODO There is still an error here, as it can cause patches/ edges to appear "crossed", when they should be parallel
        let minSpacing = 40.0 * .pi / 180.0
        var i = 0
        while i < angleInfos.count {
            var cluster = [i]
            var sumAngle = angleInfos[i].angle
            var j = i + 1
            
            while j < angleInfos.count {
                if abs(angleInfos[j].angle - angleInfos[j-1].angle) < minSpacing {
                    cluster.append(j); sumAngle += angleInfos[j].angle; j += 1
                } else { break }
            }
            
            let clusterSize = Double(cluster.count)
            if clusterSize > 1 {
                let avg = sumAngle / clusterSize
                for (k, infoIndex) in cluster.enumerated() {
                    let offset = (Double(k) - (clusterSize - 1.0)/2.0) * minSpacing
                    angleInfos[infoIndex].angle = avg + offset
                }
            }
            i = j
        }
        
        for info in angleInfos {
            participants[index].patches[info.index].angle = info.angle
        }
    }
    
    private func calculateBestAngleForPatch(_ patch: Patch, on node: Participant) -> Double? {
            // Dragging override
        if let draggingPatch = draggingStartPatch, draggingPatch.id == patch.id {
            let dx = draggingCurrentPos.x - node.position.x
            let dy = draggingCurrentPos.y - node.position.y
            return atan2(dy, dx)
        }
        
        let connectedEdges = edges.filter { $0.sourcePatchId == patch.id || $0.targetPatchId == patch.id }
        if connectedEdges.isEmpty { return nil }
        
        var sumX: Double = 0; var sumY: Double = 0
        for edge in connectedEdges {
            let otherPatchId = (edge.sourcePatchId == patch.id) ? edge.targetPatchId : edge.sourcePatchId
            if let otherNode = participants.first(where: { p in p.patches.contains(where: { $0.id == otherPatchId }) }) {
                sumX += (otherNode.position.x - node.position.x)
                sumY += (otherNode.position.y - node.position.y)
            }
        }
        return atan2(sumY, sumX)
    }
}
