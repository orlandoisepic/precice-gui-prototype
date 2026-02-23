import SwiftUI

struct CaseGenerateRunner {
    
    static func runGenerator(inputYAML: URL) -> (success: Bool, log: String) {
        
        var consoleOutput = ""
        
        func log(_ message: String) {
            print(message)
            consoleOutput += message + "\n"
        }
            // Find the binary
        guard let executableURL = Bundle.main.url(forResource: "cli", withExtension: nil) else {
            log("Error: Could not find 'cli' executable in Bundle.")
            return (false, consoleOutput)
        }
        
        log("Found binary at: \(executableURL.path)")
        log("Input YAML: \(inputYAML.path)")
        
            // Setup Process
        let task = Process()
        task.executableURL = executableURL
        task.arguments = [inputYAML.path]
        
            // 3. THE FIX: Inherit System Environment
            // PyInstaller needs to know where HOME and TMPDIR are to unpack itself.
        var env = ProcessInfo.processInfo.environment
        env["PYTHONUNBUFFERED"] = "1" // Force text to flush immediately
        env["PYTHONIOENCODING"] = "utf-8"
        task.environment = env
        
            // 4. Force Permissions (Just in case)
            // 493 = rwxr-xr-x (755)
        try? FileManager.default.setAttributes([.posixPermissions: 493], ofItemAtPath: executableURL.path)
        
            // 5. Capture Output AND Errors
        let outPipe = Pipe()
        let errPipe = Pipe()
        task.standardOutput = outPipe
        task.standardError = errPipe
        
            // 🎯 THE FIX: Set the Working Directory to the project folder
            // This ensures Python's relative paths (like '.logs') land in the right spot!
        task.currentDirectoryURL = inputYAML.deletingLastPathComponent()
        
        do {
            try task.run()
            
                // Read output
            let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
            let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
            
            task.waitUntilExit()
            
            log("\nprecice-case-generate output\n")
            
                // Print Logs for Debugging
            if let output = String(data: outData, encoding: .utf8), !output.isEmpty {
                log(output)
            }
            if let errorText = String(data: errData, encoding: .utf8), !errorText.isEmpty {
                log(errorText)
            }
            
            let status = task.terminationStatus
            if status == 0 {
                log("Success: precice-case-generate finished.")
                return (true, consoleOutput)
            } else {
                log("Failure: precice-case-generate failed with code \(status).")
                return (false, consoleOutput)
            }
            
        } catch {
            log("Critical: Failed to launch precice-case-generate: \(error)")
            return (false, consoleOutput)
        }
    }
}
