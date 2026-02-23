//
//  EdgeVisuals.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 07.02.26.
//
import SwiftUI

struct EdgeVisuals: View {
    let start: CGPoint
    let end: CGPoint
    let control: CGPoint
    let strength: EdgeStrength
    let drawProgress: CGFloat
    let isDeleting: Bool
    let isFancy: Bool
    
    var body: some View {
        Group {
            if strength == .strong {
                // Main
                DrawQuadPath(start: start, end: end, control: control)
                    .trim(from: 0, to: drawProgress)
                    .stroke(
                        (isDeleting && isFancy) ? Color.white : Color.primary,
                        style: StrokeStyle(lineWidth: (isDeleting && isFancy) ? 15 : 5, lineCap: .round)
                    )
                // Inner
                DrawQuadPath(start: start, end: end, control: control)
                    .trim(from: 0, to: drawProgress)
                    .stroke(
                        Color(nsColor: .windowBackgroundColor),
                        style: StrokeStyle(lineWidth: isDeleting ? 0 : 2, lineCap: .round)
                    )
            } else {
                // Weak
                DrawQuadPath(start: start, end: end, control: control)
                    .trim(from: 0, to: drawProgress)
                    .stroke(
                        (isDeleting && isFancy) ? Color.white : Color.gray,
                        style: StrokeStyle(lineWidth: isDeleting ? 8 : 2, lineCap: .round)
                    )
            }
        }
        .opacity(isDeleting ? 0 : 1)
        .allowsHitTesting(false)
    }
}
