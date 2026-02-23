//
//  ProjectManager.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 05.02.26.
//

import SwiftUI

struct ProjectManager {
    // The master folder: ~/case-generate/
    static var rootURL: URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appendingPathComponent("case-generate")
    }
    
    // MARK: - File System Operations
    
    // Ensures ~/case-generate exists
    static func ensureRootDirectoryExists() {
        if !FileManager.default.fileExists(atPath: rootURL.path) {
            try? FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
        }
    }
    
    /// Returns a list of all Project Names (subfolders in case-generate)
    static func listProjects() -> [String] {
        ensureRootDirectoryExists()
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: rootURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            // Filter only directories and return their names
            return urls.filter { url in
                var isDir: ObjCBool = false
                return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) && isDir.boolValue
            }.map { $0.lastPathComponent }
        } catch {
            print("Failed to list projects: \(error)")
            return []
        }
    }
    
    /// Creates a new folder for a project
    static func createProject(name: String) -> URL? {
        ensureRootDirectoryExists()
        let projectURL = rootURL.appendingPathComponent(name)
        do {
            try FileManager.default.createDirectory(at: projectURL, withIntermediateDirectories: true)
            return projectURL
        } catch {
            print("Failed to create project folder: \(error)")
            return nil
        }
    }
    
    /// Renames a project folder
    static func renameProject(oldName: String, newName: String) -> Bool {
        let oldURL = rootURL.appendingPathComponent(oldName)
        let newURL = rootURL.appendingPathComponent(newName)
        
        do {
            try FileManager.default.moveItem(at: oldURL, to: newURL)
            return true
        } catch {
            print("Rename failed: \(error)")
            return false
        }
    }
    
    /// Deletes a project folder
    static func deleteProject(name: String) {
        let url = rootURL.appendingPathComponent(name)
        try? FileManager.default.removeItem(at: url)
    }
    
    /// Helper to get the full URL for a specific project
    static func getURL(forProject name: String) -> URL {
        return rootURL.appendingPathComponent(name)
    }
    
    static func getFileURL(forProject name: String, with fileName: String) -> URL {
        print("In: \(name)/\(fileName)")
        print("Out: \(getURL(forProject: name).appendingPathComponent(fileName).path)")
        return getURL(forProject: name).appendingPathComponent(fileName)
    }
    
    static func projectExists(name: String) -> Bool {
        let url = rootURL.appendingPathComponent(name)
        var isDir: ObjCBool = false
        // It exists AND it is a directory
        return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) && isDir.boolValue
    }
    
    /// Returns a list of visible file names inside a project folder
    static func listFiles(in project: String) -> [String] {
        let projectURL = rootURL.appendingPathComponent(project)
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: projectURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            return urls
                .map { $0.lastPathComponent }
                .filter { !$0.hasPrefix(".") } // Extra safety against hidden files
                .sorted()
        } catch {
            print("Failed to list files for \(project): \(error)")
            return []
        }
    }
    
        /// Reads the content of a file as a String
    static func readFile(project: String, path: String) -> String? {
        let fileURL = rootURL.appendingPathComponent(project).appendingPathComponent(path)
        do {
            return try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            print("Failed to read file: \(error)")
            return nil
        }
    }
    
    static func moveFileToTrash(project: String, path: String) throws {
        let projectURL = getURL(forProject: project)
        let fileURL = projectURL.appendingPathComponent(path)
        
            // This is the safe macOS way to delete (puts it in the Bin)
        try FileManager.default.trashItem(at: fileURL, resultingItemURL: nil)
    }
}
