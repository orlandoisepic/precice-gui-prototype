    //
    //  GraphCanvasViewModel+FileIO.swift
    //  case-generate-app
    //
    //  Created by Orlando Ackermann on 07.02.26.
    //

import SwiftUI

extension GraphCanvasViewModel {
    
    func refreshProjectList() {
        self.availableProjects = ProjectManager.listProjects()
    }
    
    func saveProject(name: String) {
        guard let projectURL = ProjectManager.createProject(name: name) else {
            return
        }
        self.currentProjectName = name
        
        let jsonURL = projectURL.appendingPathComponent(".graph-data.json")
        let data = GraphData(participants: participants, edges: edges)
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(data)
            try jsonData.write(to: jsonURL)
            print("Saved Graph JSON")
        } catch {
            print("Failed to save JSON: \(error)")
        }
        
        hasUnsavedChanges = false
        refreshProjectList()
    }
    
    func loadProject(name: String) {
        let projectURL = ProjectManager.getURL(forProject: name)
        let jsonURL = projectURL.appendingPathComponent(".graph-data.json")
        
        do {
            let data = try Data(contentsOf: jsonURL)
            let decoded = try JSONDecoder().decode(GraphData.self, from: data)
            
            DispatchQueue.main.async {
                self.participants = decoded.participants
                self.edges = decoded.edges
                self.currentProjectName = name
                self.hasUnsavedChanges = false
                self.panOffset = .zero // Reset Camera
            }
        } catch {
            // Someone likely removed the directory. We need to refresh the list :D
            print("Failed to load project: \(error)")
            refreshProjectList()
        }
    }
    
    func clearCanvas() {
        participants = []; edges = []; currentProjectName = nil; hasUnsavedChanges = false
        withAnimation { self.panOffset = .zero }
    }
    
    func triggerAutoSave() {
        let autoSave = UserDefaults.standard.bool(forKey: "autoSaveEnabled")
        if autoSave, let projectName = currentProjectName {
            saveProject(name: projectName)
        } else {
            markDirty()
        }
    }
    
    
    func importFiles(
        _ urls: [URL],
        toProject projectName: String,
        subPath: String? = nil
    ) {
            // Get the destination folder URL
        var destinationFolder = ProjectManager.getURL(forProject: projectName)
        
        if let path = subPath {
            destinationFolder = destinationFolder.appendingPathComponent(path)
        }
        
        var failure = false
        
        for srcURL in urls {
            
            // TODO we can stil copy subfolders :/
            // Avoid copying the same folder into itself
            if srcURL == destinationFolder {
                failure = true
                break
            }
            
                // Create the destination path
            let dstURL = destinationFolder.appendingPathComponent(
                srcURL.lastPathComponent
            )
            
            
            do {
                if FileManager.default.fileExists(atPath: dstURL.path) {
                    print("File already exists: \(dstURL.lastPathComponent)")
                    failure = true
                } else {
                    try FileManager.default.copyItem(at: srcURL, to: dstURL)
                }
            } catch {
                print("Failed to copy file: \(error)")
                failure = true
            }
        }
        
        if failure {
            NSSound.beep()
        }
        
            // Triggers the view to rebuild the file tree
        refreshProjectList()
    }
    
    func moveToTrash(project: String, path: String) {
        do {
            try ProjectManager.moveFileToTrash(project: project, path: path)
            
                // This forces the file tree to rebuild without the deleted item
            refreshProjectList()
            
        } catch {
            print("Failed to move to trash: \(error)")
            NSSound.beep() // Error sound
        }
    }
}
