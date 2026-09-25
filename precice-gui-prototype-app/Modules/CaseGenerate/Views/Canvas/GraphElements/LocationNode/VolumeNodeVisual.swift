//
//  VolumeNodeVisual.swift
//  precice-gui-prototype
//
//  Created by Orlando Ackermann on 26.09.26.
//
import SwiftUI

struct VolumeNodeView: View {
    var nodeColor: Color
    var size: CGFloat
    var lineWidth: CGFloat

    var body: some View {
        Circle()
            // 1. Solid base color (no transparency)
            .fill(nodeColor)
        
            // 2. The Plastic Light Reflection
            .overlay(
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [.white.opacity(0.7), .clear]),
                            center: UnitPoint(x: 0.3, y: 0.3), // Light source from top-left
                            startRadius: size * 0.05,
                            endRadius: size * 0.5
                        )
                    )
            )
        
            // 3. The White Outline you missed
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: lineWidth)
            )
        
            // 4. Subtle drop shadow for a little UI depth
            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            .frame(width: size, height: size)
    }
}
