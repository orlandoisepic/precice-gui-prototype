//
//  GraphCanvasViewModel+Geometry.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 07.02.26.
//

import SwiftUI

extension GraphCanvasViewModel {
    
        // MARK: - Position Helpers
    func getLocationNodePosition(participant: Participant, locationNode: LocationNode) -> CGPoint {
        let x = participant.position.x + (nodeRadius * cos(locationNode.angle))
        let y = participant.position.y + (nodeRadius * sin(locationNode.angle))
        return CGPoint(x: x, y: y)
    }
    
    func findLocationNode(at location: CGPoint, excluding sourceLocationNodeId: UUID, threshold: CGFloat = 30) -> LocationNode? {
        for participant in participants {
            for locationNode in participant.locationNodes {
                if locationNode.id == sourceLocationNodeId { continue }
                let locationNodePos = getLocationNodePosition(participant: participant, locationNode: locationNode)
                if hypot(locationNodePos.x - location.x, locationNodePos.y - location.y) < threshold {
                    return locationNode
                }
            }
        }
        return nil
    }
    
    func findOwnerOfLocationNode(_ locationNodeId: UUID) -> UUID? {
        for p in participants {
            if p.locationNodes.contains(where: { $0.id == locationNodeId }) { return p.id }
        }
        return nil
    }
    
        // MARK: - "Magnetic" logic for location nodes when draggin edges
    
    func updateDynamicLocationNodeAngles(for centerNodeId: UUID) {
        updateAnglesForNode(centerNodeId)
        
            // Find connected neighbors
        let connectedEdges = edges.filter {
            let s = findOwnerOfLocationNode($0.sourceLocationNodeId)
            let t = findOwnerOfLocationNode($0.targetLocationNodeId)
            return s == centerNodeId || t == centerNodeId
        }
        
        var neighborIds = Set<UUID>()
        for edge in connectedEdges {
            if let s = findOwnerOfLocationNode(edge.sourceLocationNodeId), s != centerNodeId { neighborIds.insert(s) }
            if let t = findOwnerOfLocationNode(edge.targetLocationNodeId), t != centerNodeId { neighborIds.insert(t) }
        }
        
        for neighborId in neighborIds { updateAnglesForNode(neighborId) }
    }
    
    // Update the angles of location nodes on a participant node
    func updateAnglesForNode(_ nodeId: UUID) {
        guard let index = participants.firstIndex(where: { $0.id == nodeId }) else { return }
        let locationNodes = participants[index].locationNodes
        if locationNodes.isEmpty { return }
        
            // Calculate ideal angles
        struct LocationNodeAngleInfo { let index: Int; var angle: Double }
        var angleInfos: [LocationNodeAngleInfo] = []
        
        for i in 0..<locationNodes.count {
            let ideal = calculateBestAngleForLocationNode(locationNodes[i], on: participants[index]) ?? locationNodes[i].angle
            angleInfos.append(LocationNodeAngleInfo(index: i, angle: ideal))
        }
        
        angleInfos.sort { $0.angle < $1.angle }
        
            // A minimum spacing to avoid too close location nodes
        // TODO There is still an error here, as it can cause location nodes/ edges to appear "crossed", when they should be parallel
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
            participants[index].locationNodes[info.index].angle = info.angle
        }
    }
    
    private func calculateBestAngleForLocationNode(_ locationNode: LocationNode, on node: Participant) -> Double? {
            // Dragging override
        if let draggingLocationNode = draggingStartLocationNode, draggingLocationNode.id == locationNode.id {
            let dx = draggingCurrentPos.x - node.position.x
            let dy = draggingCurrentPos.y - node.position.y
            return atan2(dy, dx)
        }
        
        let connectedEdges = edges.filter { $0.sourceLocationNodeId == locationNode.id || $0.targetLocationNodeId == locationNode.id }
        if connectedEdges.isEmpty { return nil }
        
        var sumX: Double = 0; var sumY: Double = 0
        for edge in connectedEdges {
            let otherLocationNodeId = (edge.sourceLocationNodeId == locationNode.id) ? edge.targetLocationNodeId : edge.sourceLocationNodeId
            if let otherNode = participants.first(where: { p in p.locationNodes.contains(where: { $0.id == otherLocationNodeId }) }) {
                sumX += (otherNode.position.x - node.position.x)
                sumY += (otherNode.position.y - node.position.y)
            }
        }
        return atan2(sumY, sumX)
    }
}
