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
            // Make sure this matches the ratio in LocationNodeRing!
        let orbitRadius = locationNode.type == .surface ? participantNodeRadius : (
            participantNodeRadius * self.locationNodeInnerRingRatio
        )
        
        let x = participant.position.x + (orbitRadius * cos(locationNode.angle))
        let y = participant.position.y + (orbitRadius * sin(locationNode.angle))
        return CGPoint(x: x, y: y)
    }
    
    func findLocationNode(at location: CGPoint, excluding sourceLocationNodeId: UUID, threshold: CGFloat = 30) -> LocationNode? {
        for participant in participants {
            for locationNode in participant.locationNodes {
                if locationNode.id == sourceLocationNodeId { continue }
                let locationNodePos = getLocationNodePosition(
                    participant: participant,
                    locationNode: locationNode
                )
                if hypot(locationNodePos.x - location.x, locationNodePos.y - location.y) < threshold {
                    return locationNode
                }
            }
        }
        return nil
    }
    
    func findOwnerOfLocationNode(_ locationNodeId: UUID) -> UUID? {
        for p in participants {
            if p.locationNodes
                .contains(where: { $0.id == locationNodeId }) { return p.id }
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
            if let s = findOwnerOfLocationNode(edge.sourceLocationNodeId), s != centerNodeId {
                neighborIds.insert(s)
            }
            if let t = findOwnerOfLocationNode(edge.targetLocationNodeId), t != centerNodeId {
                neighborIds.insert(t)
            }
        }
        
        for neighborId in neighborIds { updateAnglesForNode(neighborId) }
    }
    
        // Update the angles of location nodes on a participant node
    func updateAnglesForNode(_ nodeId: UUID) {
        guard let index = participants.firstIndex(where: { $0.id == nodeId }) else {
            return
        }
        let locationNodes = participants[index].locationNodes
        if locationNodes.isEmpty { return }
        let node = participants[index]
        
        struct LocationNodeAngleInfo {
            let index: Int
            var angle: Double
            let edgeId: String
            let targetNodeId: String
            let edgeCreatedAt: Date
            let isBeingDragged: Bool
        }
        
        var infos: [LocationNodeAngleInfo] = []
        
            // 1. Calculate Base Angles (relative to participant center)
        for i in 0..<locationNodes.count {
            let loc = locationNodes[i]
            var idealAngle = loc.angle
            var edgeId = ""
            var targetNodeId = ""
            
            var edgeDate = Date.distantFuture
            var isDragged = false
            
            if let draggingLocationNode = draggingStartLocationNode, draggingLocationNode.id == loc.id {
                isDragged = true
                idealAngle = atan2(
                    draggingCurrentPos.y - node.position.y,
                    draggingCurrentPos.x - node.position.x
                )
            } else {
                let connectedEdges = edges.filter {
                    $0.sourceLocationNodeId == loc.id || $0.targetLocationNodeId == loc.id
                }
                if let firstEdge = connectedEdges.first {
                    edgeId = firstEdge.id.uuidString
                    edgeDate = firstEdge.createdAt
                    let otherLocId = (
                        firstEdge.sourceLocationNodeId == loc.id
                    ) ? firstEdge.targetLocationNodeId : firstEdge.sourceLocationNodeId
                    if let otherOwnerId = findOwnerOfLocationNode(otherLocId),
                       let otherNode = participants.first(where: { $0.id == otherOwnerId }) {
                        targetNodeId = otherOwnerId.uuidString
                            // Aiming at the participant center guarantees the bundle stays locked!
                        idealAngle = atan2(
                            otherNode.position.y - node.position.y,
                            otherNode.position.x - node.position.x
                        )
                    }
                }
            }
            infos
                .append(
                    LocationNodeAngleInfo(
                        index: i,
                        angle: idealAngle,
                        edgeId: edgeId,
                        targetNodeId: targetNodeId,
                        edgeCreatedAt: edgeDate,
                        isBeingDragged: isDragged
                    )
                )
        }
        
            // 2. Normalize to [0, 2pi)
        for i in 0..<infos.count {
            while infos[i].angle < 0 { infos[i].angle += 2 * .pi }
            while infos[i].angle >= 2 * .pi { infos[i].angle -= 2 * .pi }
        }
        infos.sort { $0.angle < $1.angle }
        
            // 3. Unwrap the circle to fix the spacing boundary bug
        var maxGap = (infos.first!.angle + 2 * .pi) - infos.last!.angle
        var splitIndex = 0
        for i in 0..<(infos.count - 1) {
            let gap = infos[i+1].angle - infos[i].angle
            if gap > maxGap {
                maxGap = gap
                splitIndex = i + 1
            }
        }
        
        var unwrappedInfos = Array(infos[splitIndex...]) + Array(
            infos[..<splitIndex]
        )
        for i in 1..<unwrappedInfos.count {
            while unwrappedInfos[i].angle < unwrappedInfos[i-1].angle {
                unwrappedInfos[i].angle += 2 * .pi
            }
        }
        
            // 4. Cluster and space out
        let minSpacing = 40.0 * .pi / 180.0
        var i = 0
        
        while i < unwrappedInfos.count {
            var cluster = [unwrappedInfos[i]]
            var sumAngle = unwrappedInfos[i].angle
            var j = i + 1
            
            while j < unwrappedInfos.count {
                if abs(unwrappedInfos[j].angle - unwrappedInfos[j-1].angle) < minSpacing {
                    cluster.append(unwrappedInfos[j])
                    sumAngle += unwrappedInfos[j].angle
                    j += 1
                } else { break }
            }
            
            let avg = sumAngle / Double(cluster.count)
            
                // Sort the cluster cleanly and deterministically
            cluster.sort { a, b in
                    // PRIORITY 1: Respect the mouse during a drag
                if a.isBeingDragged || b.isBeingDragged {
                    return a.angle < b.angle
                }
                
                    // PRIORITY 2: Group by target participant
                if a.targetNodeId != b.targetNodeId {
                    return a.targetNodeId < b.targetNodeId
                }
                
                    // PRIORITY 3: Tie-breaker for edges going to the SAME participant
                    // Mirror the order for one side to guarantee lines stay perfectly parallel
                if !a.targetNodeId.isEmpty && nodeId.uuidString > a.targetNodeId {
                    return a.edgeCreatedAt > b.edgeCreatedAt // Reversed order for the target node
                }
                return a.edgeCreatedAt < b.edgeCreatedAt // Normal order for the source node
            }
            
                // Apply spacing offsets
            for (k, info) in cluster.enumerated() {
                let offset = (
                    Double(k) - (Double(cluster.count) - 1.0)/2.0
                ) * minSpacing
                
                if let originalIndex = infos.firstIndex(where: { $0.index == info.index }) {
                    infos[originalIndex].angle = avg + offset
                }
            }
            i = j
        }
        
            // Apply the calculated angles back to the location nodes
        for info in infos {
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
        
        let connectedEdges = edges.filter {
            $0.sourceLocationNodeId == locationNode.id || $0.targetLocationNodeId == locationNode.id
        }
        if connectedEdges.isEmpty { return nil }
        
        var sumX: Double = 0; var sumY: Double = 0
        for edge in connectedEdges {
            let otherLocationNodeId = (
                edge.sourceLocationNodeId == locationNode.id
            ) ? edge.targetLocationNodeId : edge.sourceLocationNodeId
            
            if let otherNode = participants.first(
                where: { p in p.locationNodes.contains(
                    where: { $0.id == otherLocationNodeId
                    })
                }),
               let otherLocNode = otherNode.locationNodes.first(where: { $0.id == otherLocationNodeId }) {
                
                    // Aim at the actual x,y coordinates of the target location node to avoid crossing edges
                let otherPos = getLocationNodePosition(
                    participant: otherNode,
                    locationNode: otherLocNode
                )
                sumX += (otherPos.x - node.position.x)
                sumY += (otherPos.y - node.position.y)
            }
        }
        return atan2(sumY, sumX)
    }
}
