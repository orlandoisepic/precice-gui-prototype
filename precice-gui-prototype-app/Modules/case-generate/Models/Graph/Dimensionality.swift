//
//  Dimensionality.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 07.02.26.
//


import SwiftUI

// 1. Define the Types
enum ParticipantDimensionality: String, Codable, CaseIterable {
    case twoD = "2D"
    case threeD = "3D"
    
    // Helper for visual labels
    var label: String {
        switch self {
        case .twoD: return "2D"
        case .threeD: return "3D"
        }
    }
    
    // Helper for badge colors
    var color: Color {
        switch self {
        case .twoD: return .teal       // 2D = Flat/Cyan
        case .threeD: return .purple   // 3D = Deep/Purple
        }
    }
}
