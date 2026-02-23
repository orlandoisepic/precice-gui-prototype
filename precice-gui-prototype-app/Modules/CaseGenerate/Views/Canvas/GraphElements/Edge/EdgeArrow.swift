//
//  EdgeArrow.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 07.02.26.
//
import SwiftUI

struct EdgeArrow: View {
    let start: CGPoint
    let end: CGPoint
    let control: CGPoint
    let strength: EdgeStrength
    let drawProgress: CGFloat
    let isDeleting: Bool
    let isFancy: Bool
    
    var body: some View {
        let t: CGFloat = 0.75
        let pos = calculatePoint(t: t, p0: start, p1: control, p2: end)
        let angle = calculateAngle(t: t, p0: start, p1: control, p2: end)
        
        Image(systemName: "chevron.right.circle.fill")
            .resizable()
            .frame(width: 14, height: 14)
            .background(Color(nsColor: .windowBackgroundColor).clipShape(Circle()))
            .foregroundStyle(strength == .strong ? .primary : .secondary)
            .rotationEffect(Angle(radians: angle))
            .position(pos)
            .opacity(isDeleting ? 0 : (drawProgress > 0.75 ? 1.0 : 0.0))
            .scaleEffect(isDeleting ? (isFancy ? 1.5 : 0.8) : 1.0)
            .allowsHitTesting(false)
    }
    
    func calculatePoint(t: CGFloat, p0: CGPoint, p1: CGPoint, p2: CGPoint) -> CGPoint {
        let x = pow(1 - t, 2) * p0.x + 2 * (1 - t) * t * p1.x + pow(t, 2) * p2.x
        let y = pow(1 - t, 2) * p0.y + 2 * (1 - t) * t * p1.y + pow(t, 2) * p2.y
        return CGPoint(x: x, y: y)
    }
    
    func calculateAngle(t: CGFloat, p0: CGPoint, p1: CGPoint, p2: CGPoint) -> Double {
        let dx = 2 * (1 - t) * (p1.x - p0.x) + 2 * t * (p2.x - p1.x)
        let dy = 2 * (1 - t) * (p1.y - p0.y) + 2 * t * (p2.y - p1.y)
        return atan2(dy, dx)
    }
}
