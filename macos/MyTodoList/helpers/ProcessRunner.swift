//
import Foundation

func executeProcess(command : String) -> String? {
    let currentFileURL = URL(fileURLWithPath: #file)
    let currentFolderURL = currentFileURL.deletingLastPathComponent()
    let parentFolderURL = currentFolderURL.deletingLastPathComponent()
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/sh")
    process.arguments = ["-c", command]
    process.currentDirectoryURL = parentFolderURL
    
    let outputPipe = Pipe()
    process.standardOutput = outputPipe
    
    do {
        try process.run()
        process.waitUntilExit()
        
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            return output
        }
    } catch {
        return ("Error occurred: \(error)")
    }
    
    return nil
}
