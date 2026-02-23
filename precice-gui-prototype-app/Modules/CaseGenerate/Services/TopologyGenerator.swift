//
//  TopologyGenerator.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 05.02.26.
//

import SwiftUI

struct TopologyGenerator {
    
    // Generates a YAML string adhering to the topology-schema.json
    static func generateYAML(participants: [Participant], edges: [Edge]) -> String {
        var yaml = ""
        
        // 1. PARTICIPANTS SECTION
        yaml += "participants:\n"
        
        for node in participants {
            
            // Indent list items with 2 spaces
            yaml += "  - name: \(node.name)\n"
            let solverName: String = node.solver.isEmpty ? "Solver" : node.solver
            yaml += "    solver: \(solverName)\n"
            
            if let dim = node.dimensionality {
                yaml += "    dimensionality: \(dim == .twoD ? 2 : 3)\n"
            }
            
        }
        
        yaml += "\n"
        
        // 2. EXCHANGES SECTION
        yaml += "exchanges:\n"
        
        for edge in edges {
                // We need to resolve IDs back to Names
            guard let sourceInfo = findNodeAndPatch(participants: participants, patchId: edge.sourcePatchId),
                  let targetInfo = findNodeAndPatch(participants: participants, patchId: edge.targetPatchId) else {
                print("Warning: skipped edge \(edge.id) because nodes could not be found.")
                continue
            }
            
            yaml += "  - from: \(sourceInfo.nodeName)\n"
            yaml += "    from-patch: \(sourceInfo.patchName)\n"
            yaml += "    to: \(targetInfo.nodeName)\n"
            yaml += "    to-patch: \(targetInfo.patchName)\n"
            yaml += "    data: \(edge.data)\n"
            
                // Map our internal Enums to the Schema Strings
            if let type = edge.dataType {
                yaml += "    data-type: \(type == .vector ? "vector" : "scalar")\n"
            }
            // Schema: "strong", "weak"
            let strengthStr = (edge.strength == .strong) ? "strong" : "weak"
            yaml += "    type: \(strengthStr)\n"
        }
        
        return yaml
    }
    
    // Helper to look up names from IDs
    private static func findNodeAndPatch(participants: [Participant], patchId: UUID) -> (nodeName: String, patchName: String)? {
        for node in participants {
            if let patch = node.patches.first(where: { $0.id == patchId }) {
                return (node.name, patch.name)
            }
        }
        return nil
    }
    /// Check if the graph is syntactically correct and return any errors found
    static func validateGraph(participants: [Participant], edges: [Edge]) -> [String] {
        var errors: [String] = []
        
        var participantNames: [String] = []

        
            // 1. Basic Checks
        if participants.isEmpty { errors.append("Graph must have at least one participant.") }
        
        // Check that each participant has a unique name
        for participant in participants {
            if participantNames.contains(participant.name) {
                errors.append("Duplicate participant name: '\(participant.name)'")
            }
            else {
                participantNames.append(participant.name)
            }
        }
        
        print("participant names: \(participantNames)")
        
        if edges.isEmpty {errors.append("Graph must have at least one edge.")}
        
        var edgeValues: [[String]] = []
        
        // Edges must be unique
        for edge in edges {
            
            guard let sourceInfo = findNodeAndPatch(participants: participants,patchId: edge.sourcePatchId),
                  let targetInfo = findNodeAndPatch(participants: participants, patchId: edge.targetPatchId) else {
                errors.append("Edge conects to a missing patch.")
                continue
            }
            
            // Get values of edge to compare
            let sourceParticipant: String = sourceInfo.nodeName
            let sourcePath: String = sourceInfo.patchName
            let targetParticipant: String = targetInfo.nodeName
            let targetPath: String = targetInfo.patchName
            let strength: String = edge.strength.rawValue
            let data: String = edge.data
            let dataType: String = edge.dataType?.rawValue ?? ""
            
            let edgeList: [String] = [sourceParticipant, sourcePath, targetParticipant, targetPath, strength, data, dataType]
            
            if edgeValues.contains(edgeList) {
                errors.append("Duplicate edge between \(sourceParticipant) and \(targetParticipant).")
            }
            
            edgeValues.append(edgeList)
            
        }
        return errors
    }
}
