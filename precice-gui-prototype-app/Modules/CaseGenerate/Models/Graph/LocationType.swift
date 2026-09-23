//
//  LocationType.swift
//  precice-gui-prototype
//
//  Created by Orlando Ackermann on 21.09.26.
//


import SwiftUI

enum LocationType: String, Codable, CaseIterable {
    case surface = "surface"
    case volume = "volume"
    
    // For UI labels (e.g., in context menus or inspectors)
    var label: String {
        switch self {
        case .surface: return "Surface"
        case .volume: return "Volume"
        }
    }

}


