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
        let orbitRadius = locationNode.type == .surface ? participantNodeRadius : (
            participantNodeRadius * self.locationNodeInnerRingRatio
        )
        
        let x = participant.position.x + (orbitRadius * cos(locationNode.angle))
        let y = participant.position.y + (orbitRadius * sin(locationNode.angle))
        return CGPoint(x: x, y: y)
    }
    
        /// Find the location node closest to the location, within the treshold
    func findLocationNode(at location: CGPoint, excluding sourceLocationNodeId: UUID, threshold: CGFloat = 30) -> LocationNode? {
        
        var closestNode: LocationNode? = nil
        var shortestDistance: CGFloat = threshold // Start with the maximum allowed distance
        
        for participant in participants {
            for locationNode in participant.locationNodes {
                if locationNode.id == sourceLocationNodeId { continue }
                
                let locationNodePos = getLocationNodePosition(
                    participant: participant,
                    locationNode: locationNode
                )
                
                let distance = hypot(
                    locationNodePos.x - location.x,
                    locationNodePos.y - location.y
                )
                
                    // Only update if it is closer than the previous closest node
                if distance < shortestDistance {
                    shortestDistance = distance
                    closestNode = locationNode
                }
            }
        }
        
        return closestNode
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
            let currentPhysicalAngle: Double
            let targetNodeId: String
            let targetLocAbsolutePos: CGPoint? // The exact (x,y) of the target location node
        }
        
        var infos: [LocationNodeAngleInfo] = []
        
            // 1. Calculate Base Angles (relative to participant center)
        for i in 0..<locationNodes.count {
            let loc = locationNodes[i]
            var idealAngle = loc.angle
            var targetNodeId = ""
            var targetLocAbsolutePos: CGPoint? = nil // Track the target
            
            if let draggingLocationNode = draggingStartLocationNode, draggingLocationNode.id == loc.id {
                idealAngle = atan2(
                    draggingCurrentPos.y - node.position.y,
                    draggingCurrentPos.x - node.position.x
                )
                targetLocAbsolutePos = draggingCurrentPos // Use mouse position
            } else {
                let connectedEdges = edges.filter {
                    $0.sourceLocationNodeId == loc.id || $0.targetLocationNodeId == loc.id
                }
    
                if !connectedEdges.isEmpty {
                    var sumVectorX: Double = 0
                    var sumVectorY: Double = 0
                    var validTargets = 0
                    var primaryTargetId = ""
        
                    for edge in connectedEdges {
                        let otherLocId = (
                            edge.sourceLocationNodeId == loc.id
                        ) ? edge.targetLocationNodeId : edge.sourceLocationNodeId
            
                        if let otherOwnerId = findOwnerOfLocationNode(
                            otherLocId
                        ),
                           let otherNode = participants.first(
                            where: { $0.id == otherOwnerId
                            }),
                           let otherLocNode = otherNode.locationNodes.first(where: { $0.id == otherLocId }) {
                
                                // Keep the first target ID for grouping purposes
                            if primaryTargetId.isEmpty {
                                primaryTargetId = otherOwnerId.uuidString
                            }
                
                            let targetPos = getLocationNodePosition(
                                participant: otherNode,
                                locationNode: otherLocNode
                            )
                
                                // Calculate the direction vector
                            let dx = targetPos.x - node.position.x
                            let dy = targetPos.y - node.position.y
                            let distance = max(
                                hypot(dx, dy),
                                1.0
                            ) // Prevent division by zero
                
                                // Normalize the vector (so its length is exactly 1) and add it to our sum
                            sumVectorX += dx / distance
                            sumVectorY += dy / distance
                
                            validTargets += 1
                        }
                    }
        
                    if validTargets > 0 {
                        targetNodeId = primaryTargetId
            
                            // The new ideal angle is exactly the average of all the direction vectors
                        idealAngle = atan2(sumVectorY, sumVectorX)
            
                            // For the sorting algorithm, we project a "phantom" target point in that exact direction
                        targetLocAbsolutePos = CGPoint(
                            x: node.position.x + sumVectorX,
                            y: node.position.y + sumVectorY
                        )
                    }
                }
            }
            
            infos.append(LocationNodeAngleInfo(
                index: i,
                angle: idealAngle,
                currentPhysicalAngle: loc.angle,
                targetNodeId: targetNodeId,
                targetLocAbsolutePos: targetLocAbsolutePos
            ))
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
        let clusterThreshold = 60.0 * .pi / 180.0 // How wide the net is to group them
        let visualSpacing = 35.0 * .pi / 180.0    // How tightly they actually sit on the circle
        
        var i = 0
        while i < unwrappedInfos.count {
            var cluster = [unwrappedInfos[i]]
            var sumAngle = unwrappedInfos[i].angle
            var j = i + 1
            
            while j < unwrappedInfos.count {
                    // Use clusterThreshold to decide if they belong together
                if abs(unwrappedInfos[j].angle - unwrappedInfos[j-1].angle) < clusterThreshold {
                    cluster.append(unwrappedInfos[j])
                    sumAngle += unwrappedInfos[j].angle
                    j += 1
                } else { break }
            }
            
            let avg = sumAngle / Double(cluster.count)
            

                // Sort the cluster to mathematically prevent crossed edges
                // Grab a stable anchor from the cluster so the math doesn't wrap around
            let clusterAnchor = cluster.first!.angle
            
            cluster.sort { a, b in
                func getAimDelta(for info: LocationNodeAngleInfo) -> Double {
                    guard let targetPos = info.targetLocAbsolutePos else {
                        return 0
                    }
                    let aimAngle = atan2(
                        targetPos.y - node.position.y,
                        targetPos.x - node.position.x
                    )
                    return atan2(
                        sin(aimAngle - clusterAnchor),
                        cos(aimAngle - clusterAnchor)
                    )
                }
                
                let deltaA = getAimDelta(for: a)
                let deltaB = getAimDelta(for: b)
                
                if deltaA == deltaB {
                    return a.index < b.index
                }
                
                return deltaA < deltaB
            }
            
                // Apply spacing offsets
            for (k, info) in cluster.enumerated() {
                    // Use visualSpacing to calculate the actual physical layout
                let offset = (
                    Double(k) - (Double(cluster.count) - 1.0)/2.0
                ) * visualSpacing
                
                if let originalIndex = infos.firstIndex(where: { $0.index == info.index }) {
                    infos[originalIndex].angle = avg + offset
                }
            }
            i = j
        }
        
            // Apply the calculated angles back to the location nodes
        let isActivelyDragging = (draggingStartLocationNode != nil)
        
        if isActivelyDragging {
                // Apply instantly during drag to reduce lag
            for info in infos {
                participants[index].locationNodes[info.index].angle = info.angle
            }
        } else {
                // Animate to make it smooth once the drag is over
            withAnimation(.spring(response: self.nodeMovementResponse, dampingFraction: self.nodeMovementDamping)) {
                for info in infos {
                    participants[index].locationNodes[info.index].angle = info.angle
                }
            }
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
