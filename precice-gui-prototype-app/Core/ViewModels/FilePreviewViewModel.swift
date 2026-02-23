
//
//  FilePreviewViewModel.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 08.02.26.
//

import SwiftUI
import Combine

class FilePreviewViewModel: ObservableObject {
    @Published var content: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
        // ✅ Track if the user has unsaved changes
    @Published var isDirty: Bool = false
    
    private var watcher: FileWatcher?
    private var currentData: PreviewData?
    
    private var isSavingInternal = false
    
    // Called when the View appears or the file selection changes
    func loadFile(data: PreviewData) {
        // 1. Stop previous watcher if we are switching files
        if let current = currentData, current.path != data.path || current.project != data.project {
            watcher?.stop()
            watcher = nil
        }
        
        self.currentData = data
        let fullPath = ProjectManager.getURL(forProject: data.project).appendingPathComponent(data.path)
        
        // 2. Initial Load
        performRead(url: fullPath)
        
        // 3. Start Watching
        self.watcher = FileWatcher(url: fullPath) { [weak self] in
            print("📝 File changed externally: reloading...")
            self?.performRead(url: fullPath)
        }
        self.watcher?.start()
    }
    
    private func performRead(url: URL) {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        // Reading off the main thread to prevent UI freezing for large files
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let text = try String(contentsOf: url, encoding: .utf8)
                DispatchQueue.main.async {
                    self.content = text
                    self.isLoading = false
                    self.errorMessage = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load file: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
        // ✅ NEW: Save Function
    func saveFile() {
        guard let data = currentData else { return }
        let url = ProjectManager.getURL(forProject: data.project).appendingPathComponent(data.path)
        
        isSavingInternal = true // 🔒 Lock the watcher
        
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
            print("Saved successfully")
            
                // Reset Dirty State
            DispatchQueue.main.async {
                self.isDirty = false
            }
            
                // 🔓 Unlock the watcher after a short delay (to let file system events settle)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isSavingInternal = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to save: \(error.localizedDescription)"
                self.isSavingInternal = false // Unlock on failure
            }
        }
    }
    
    // Cleanup when the view disappears
    func stopWatching() {
        watcher?.stop()
    }
}
