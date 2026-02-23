//
//  FileWatcher.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 08.02.26.
//


//
//  FileWatcher.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 08.02.26.
//

import SwiftUI

class FileWatcher {
    private let url: URL
    private let onChange: () -> Void
    
    private var fileDescriptor: Int32 = -1
    private var source: DispatchSourceFileSystemObject?
    private let queue = DispatchQueue(label: "com.precice-utility.filewatcher", attributes: .concurrent)
    
    init(url: URL, onChange: @escaping () -> Void) {
        self.url = url
        self.onChange = onChange
    }
    
    deinit {
        stop()
    }
    
    func start() {
        guard source == nil else { return }
        
        // 1. Open the file strictly for monitoring (O_EVTONLY)
        // We use the raw POSIX open() call to get a file descriptor
        let path = url.path
        let fd = open(path, O_EVTONLY)
        
        guard fd >= 0 else {
            print("Watcher failed to open: \(path)")
            return
        }
        
        self.fileDescriptor = fd
        
        // 2. Create the Dispatch Source
        // We listen for:
        // - .write (Content changed)
        // - .delete (File deleted/replaced - Atomic Save)
        // - .rename (File moved/renamed - Atomic Save)
        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: [.write, .delete, .rename, .extend],
            queue: queue
        )
        
        source.setEventHandler { [weak self] in
            guard let self = self else { return }
            let event = source.data
            
            if event.contains(.write) || event.contains(.extend) {
                // Simple write: Just notify
                DispatchQueue.main.async { self.onChange() }
            }
            
            if event.contains(.delete) || event.contains(.rename) {
                // ⚠️ Atomic Save Detected!
                // The editor deleted the file we were watching and replaced it with a new one.
                // Our current file handle is now pointing to a ghost file.
                // We must restart the watcher to grab the NEW file handle.
                self.stop()
                
                // Wait a tiny bit for the file system to settle, then restart
                self.queue.asyncAfter(deadline: .now() + 0.1) {
                    self.start()
                    DispatchQueue.main.async { self.onChange() }
                }
            }
        }
        
        source.setCancelHandler {
            close(fd)
        }
        
        source.resume()
        self.source = source
    }
    
    func stop() {
        source?.cancel()
        source = nil
        // Note: 'close(fd)' happens in the cancel handler automatically
    }
}
