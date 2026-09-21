import SwiftUI

struct LogFormatter {
    
    static func formatText(_ rawLog: String) -> Text {
            // 1. Remove Timestamps like [11:02:39]
        let timestampPattern = #"(?m)^\[\d{2}:\d{2}:\d{2}\]\s?"#
        let cleanLog = rawLog.replacingOccurrences(of: timestampPattern, with: "", options: .regularExpression)
        
            // 2. Split by the ANSI Escape character \u{1b}
        let parts = cleanLog.components(separatedBy: "\u{1b}")
        var result = Text("")
        
        for part in parts {
            if part.isEmpty { continue }
            
            if part.hasPrefix("["), let mIndex = part.firstIndex(of: "m") {
                let code = String(part[part.index(after: part.startIndex)..<mIndex])
                let content = String(part[part.index(after: mIndex)...])
                let colored = Text(content).foregroundColor(colorForCode(code))
                
                result = Text("\(result)\(colored)")
            } else {
                result = Text("\(result)\(part)")
            }
        }
        return result
    }
    
        /// Removes timestamps and string escape codes
    static func cleanString(_ rawLog: String) -> String {
            // Remove Timestamps
        let timestampPattern = #"(?m)^\[\d{2}:\d{2}:\d{2}\]\s?"#
        let noTimestamps = rawLog.replacingOccurrences(of: timestampPattern, with: "", options: .regularExpression)
        
            // Catch the actual escape character (\x1B or \u{1b}) along with the color code
        let colorCode = #"\x1B\[[0-9;]*[a-zA-Z]"#
        let cleanString = noTimestamps.replacingOccurrences(of: colorCode, with: "", options: .regularExpression)
        
        return cleanString
    }
    
    private static func colorForCode(_ code: String) -> Color {
        switch code {
        case "31", "1;31", "38;5;1": return .red
        case "32", "1;32", "38;5;2": return .green
        case "33", "1;33", "38;5;3": return .yellow
        case "34", "1;34", "38;5;4": return .blue
        case "35", "1;35", "38;5;5": return .purple
        case "36", "1;36", "38;5;6": return .cyan
        case "0": return .primary // Reset
        default:
            print("Unrecognized color code: \(code)") // Helps debug unknown colors
            return .primary
        }
    }
}
