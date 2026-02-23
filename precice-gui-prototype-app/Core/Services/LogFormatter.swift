//
//  LogFormatter.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 08.02.26.
//


import SwiftUI

struct LogFormatter {
    
    static func formatText(_ rawLog: String) -> Text {
        // 1. Remove Timestamps like [11:02:39]
        // Matches a bracket, 2 digits, colon, 2 digits, colon, 2 digits, bracket, and optional space
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
        print(result)
        return result
    }
    
        /// Removes timestamps and string escape codes
    static func cleanString(_ rawLog: String) -> String {
            // Remove Timestamps
        let timestampPattern = #"(?m)^\[\d{2}:\d{2}:\d{2}\]\s?"#
        let noTimestamps = rawLog.replacingOccurrences(of: timestampPattern, with: "", options: .regularExpression)
        
            // Remove color escape codes
        let colorCode = #"\[+[0-9]+m"#
        let cleanString = noTimestamps.replacingOccurrences(of: colorCode, with: "", options: .regularExpression)

        return cleanString
    }
    
    private static func colorForCode(_ code: String) -> Color {
        switch code {
        case "31", "1;31": return .red
        case "32", "1;32": return .green
        case "33", "1;33": return .yellow
        case "34", "1;34": return .blue
        case "35", "1;35": return .purple
        case "36", "1;36": return .cyan
        case "0": return .primary // Reset
        default: return .primary
        }
    }
}
