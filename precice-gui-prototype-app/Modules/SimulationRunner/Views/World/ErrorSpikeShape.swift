//
//  ErrorSpikeShape.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 08.02.26.
//

import SwiftUI

struct ErrorSpikeShape: Shape {
    
    var tipOffset: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let start = CGPoint(x: 0, y: 1.0)
        let end = CGPoint(x: 1.0, y: 1.0)
            // Points of the spike
        let leftShoulder = CGPoint(x: 0.2, y: 0.6)
        let leftDip = CGPoint(x: 0.05, y: 0.45)
        let tip = CGPoint(x: 0.4 + tipOffset, y: 0.0)
        let rightShoulder = CGPoint(x: 1.0, y: 0.3)
        let rightDip = CGPoint(x: 0.7, y: 0.7)
            // Draw
        path.move(to: map(start, rect))
        path.addLine(to: map(leftShoulder, rect))
        path.addLine(to: map(leftDip, rect))
        path.addLine(to: map(tip, rect))
        path.addLine(to: map(rightShoulder, rect))
        path.addLine(to: map(rightDip, rect))
        path.addLine(to: map(end, rect))
        
        path.closeSubpath()
        return path
    }
        // Helper to map normalized points to the specific rect
    private func map(_ point: CGPoint, _ rect: CGRect) -> CGPoint {
        return CGPoint(
            x: point.x * rect.width,
            y: point.y * rect.height
        )
    }
}
