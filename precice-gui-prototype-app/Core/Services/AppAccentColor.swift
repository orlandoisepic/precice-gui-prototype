//
//  AppAccentColor.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 07.02.26.
//
import SwiftUI

// 1. Define the Palette 🎨
enum AppAccentColor: String, CaseIterable, Codable {
    case blue, purple, pink, red, orange, yellow, green, gray
    
    // The visual color for SwiftUI
    var color: Color {
        switch self {
        case .blue: return .blue
        case .purple: return .purple
        case .pink: return .pink
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .gray: return .gray
        }
    }
    
    // A display name for tooltips (optional)
    var label: String {
        rawValue.capitalized
    }
}
