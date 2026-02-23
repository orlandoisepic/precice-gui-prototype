//
//  Obstacle.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 08.02.26.
//
import SwiftUI

struct Obstacle: Identifiable {
        let id = UUID()
        var x: CGFloat
        
        let heightFactor: CGFloat
        let widthFactor: CGFloat
        let tipOffset: CGFloat
    }
