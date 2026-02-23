    //
    //  GraphCanvasViewModel+CaseGenerate.swift
    //  case-generate-app
    //
    //  Created by Orlando Ackermann on 07.02.26.
    //

import SwiftUI

extension GraphCanvasViewModel {
        
    func runSimulation(topologyPath: URL? = nil) {
        // Only if the path is not nil run directly from it
        if let topologyPath = topologyPath {
            runDetachedSimulation(topologyPath: topologyPath)
            // Otherwise, run from the current project
        } else {
            runAttachedSimulation()
        }
    }
        
        // Run directly from the file (do not load the project graph)
    private func runDetachedSimulation(topologyPath: URL) {
        print("Running Detached Simulation...")
        self.generationState = .running
            // This shouldn't happen since we are pointing directly to it
        if !FileManager.default.fileExists(atPath: topologyPath.path) {
            self.generationState = .error(
                title: "File Missing",
                message: "topology.yaml not found.",
                details: ""
            )
            return
        }
        // Run executable
        executeRunner(inputPath: topologyPath)
    }
        // Run from the current project
    private func runAttachedSimulation() {
        guard let name = currentProjectName else {
            self.generationState = 
                .error(
                    title: "No Project selected",
                    message: "Please save the current project first.",
                    details: nil
                )
            return
        }
            
        print("Running attached simulation.")
        
        self.generationState = .running
            
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
                
            saveProject(name: name)
                
                // Validate to avoid empty graph / duplicate items
            let validationErrors = TopologyGenerator.validateGraph(
                participants: participants,
                edges: edges
            )
            if !validationErrors.isEmpty {
                let details = validationErrors.map { "> " + $0 }.joined(
                    separator: "\n"
                )
                self.generationState = .error(
                    title: "Invalid Graph",
                    message: "The graph contains errors.",
                    details: details
                )
                return
            }
                
                // Write topology file
            guard let exportedPath = exportTopology() else {
                self.generationState = 
                    .error(
                        title: "Export Failed",
                        message: "Could not write YAML.",
                        details: nil
                    )
                return
            }
                
                // Run executable
            executeRunner(inputPath: exportedPath)
                
            removeDetached(path: exportedPath)
            print("removed detached: \(exportedPath)")
        }
    }
        
        /// Call the executable file with the given path to the topology
    private func executeRunner(inputPath: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = CaseGenerateRunner.runGenerator(inputYAML: inputPath)
                
            DispatchQueue.main.async {
                if result.success {
                    withAnimation {
                        self.generationState = .success(log: result.log)
                    }
                } else {
                    withAnimation {
                        self.generationState = .error(
                            title: "Simulation Failed",
                            message: "The process encountered an error.",
                            details: result.log
                        )
                    }
                }
            }
        }
    }
    
    func exportTopology() -> URL? {
        guard let name = currentProjectName else { return nil }
        let fileURL = ProjectManager.getURL(forProject: name).appendingPathComponent(
            "topology.yaml"
        )
        let yamlContent = TopologyGenerator.generateYAML(
            participants: participants,
            edges: edges
        )
        
        do {
            try yamlContent
                .write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Failed to export YAML: \(error)")
            return nil
        }
    }
}
