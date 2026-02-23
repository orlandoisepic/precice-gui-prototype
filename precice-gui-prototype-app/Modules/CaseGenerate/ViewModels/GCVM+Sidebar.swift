//
//  GCVM+Sidebar.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 07.02.26.
//

import SwiftUI

extension GraphCanvasViewModel {
    
        // MARK: - Project management
    
    func isProjectNameAvailable(_ name: String) -> Bool {
            // Case insensitive check is safer for file systems
        return !ProjectManager.projectExists(name: name)
    }
    
    func renameProject(oldName: String, newName: String) {
        if ProjectManager.renameProject(oldName: oldName, newName: newName) {
            refreshProjectList()
            if currentProjectName == oldName {
                currentProjectName = newName
            }
        }
    }
    
    func deleteProject(name: String) {
        ProjectManager.deleteProject(name: name)
        
            // If we deleted the currently open project, clear the canvas
        if currentProjectName == name {
            clearCanvas()
        }
        refreshProjectList()
    }
    
        // MARK: - File tree
    
        // Helper to get files for the sidebar
    func getProjectFiles(_ projectName: String) -> [String] {
        return ProjectManager.listFiles(in: projectName)
    }
    
        // Recursively builds a tree of FileNodes for a given project
    func getProjectFileTree(_ projectName: String) -> [FileNode] {
        let projectURL = ProjectManager.getURL(forProject: projectName)
            // Start the recursion
        return buildTree(at: projectURL, rootPath: projectURL.path, relativePrefix: "")
    }
    
        // Recursive helper to display project/file tree
    private func buildTree(at url: URL, rootPath: String, relativePrefix: String) -> [FileNode] {
        var nodes: [FileNode] = []
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            )
            
                // Sort alphabetically and display folders before files
            let sortedContents = contents.sorted { url1, url2 in
                let isDir1 = (try? url1.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                let isDir2 = (try? url2.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                
                if isDir1 != isDir2 { return isDir1 } // Folders on top
                return url1.lastPathComponent < url2.lastPathComponent
            }
            
            for itemURL in sortedContents {
                let name = itemURL.lastPathComponent
                    // Skip system files
                if name == ".DS_Store" { continue }
                
                let isDirectory = (try? itemURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                
                    // Calculate relative path for display/logic
                let relativePath = relativePrefix.isEmpty ? name : "\(relativePrefix)/\(name)"
                
                if isDirectory {
                        // Recursively call to get children
                    let children = buildTree(at: itemURL, rootPath: rootPath, relativePrefix: relativePath)
                    nodes.append(FileNode(name: name, path: relativePath, isDirectory: true, children: children))
                } else {
                    nodes.append(FileNode(name: name, path: relativePath, isDirectory: false, children: nil))
                }
            }
        } catch {
            print("Error scanning directory: \(error)")
        }
        
        return nodes
    }
}
