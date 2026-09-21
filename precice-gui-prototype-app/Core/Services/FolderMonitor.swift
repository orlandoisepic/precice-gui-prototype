import Foundation
import CoreServices // Required for FSEvents

class FolderMonitor {
    private var stream: FSEventStreamRef?
    var folderDidChange: (() -> Void)?
    
    init(url: URL) {
        let pathsToWatch = [url.path] as CFArray
        
            // Create a bridge so the C-callback can talk to this Swift class
        var context = FSEventStreamContext(
            version: 0,
            info: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            retain: nil,
            release: nil,
            copyDescription: nil
        )
        
            // The callback that macOS triggers when ANY file deep in the folder changes
        let callback: FSEventStreamCallback = { (streamRef, clientCallBackInfo, numEvents, eventPaths, eventFlags, eventIds) in
            guard let info = clientCallBackInfo else { return }
            let monitor = Unmanaged<FolderMonitor>.fromOpaque(info).takeUnretainedValue()
            
                // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                monitor.folderDidChange?()
            }
        }
        
            // Setup the recursive FSEvent stream
        stream = FSEventStreamCreate(
            kCFAllocatorDefault,
            callback,
            &context,
            pathsToWatch,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            0.5, // 0.5 second delay to batch rapid file generations together
            UInt32(kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents)
        )
    }
    
    func startMonitoring() {
        guard let stream = stream else { return }
        FSEventStreamSetDispatchQueue(stream, DispatchQueue.global(qos: .background))
        FSEventStreamStart(stream)
    }
    
    func stopMonitoring() {
        guard let stream = stream else { return }
        FSEventStreamStop(stream)
        FSEventStreamInvalidate(stream)
        FSEventStreamRelease(stream)
        self.stream = nil
    }
}
