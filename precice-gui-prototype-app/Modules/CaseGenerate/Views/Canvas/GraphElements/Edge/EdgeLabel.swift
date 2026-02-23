//
//  EdgeLabel.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 07.02.26.
//

import SwiftUI

struct EdgeLabel: View {
    let start: CGPoint
    let end: CGPoint
    let control: CGPoint
    let perpVector: CGVector
    @Binding var edge: Edge
    let drawProgress: CGFloat
    let isDeleting: Bool
    
    var body: some View {
        let t: CGFloat = 0.5
        let x = pow(1 - t, 2) * start.x + 2 * (1 - t) * t * control.x + pow(t, 2) * end.x
        let y = pow(1 - t, 2) * start.y + 2 * (1 - t) * t * control.y + pow(t, 2) * end.y
        let midPos = CGPoint(x: x, y: y)
        
        let textPos = CGPoint(
            x: midPos.x + (perpVector.dx * 20),
            y: midPos.y + (perpVector.dy * 20)
        )
        
        VStack(spacing: 0) {
            Image(systemName: "arrow.right")
                .opacity(edge.dataType == .vector ? 1.0 : 0.0)
                .scaleEffect(edge.dataType == .vector ? 1.0 : 0.5)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.primary)
                .help("Data is of type vector")
            
            TextField("Data", text: $edge.data)
                .textFieldStyle(.plain)
                .multilineTextAlignment(.center)
                .padding(4)
                .background(.ultraThinMaterial.opacity(0.75))
                .cornerRadius(12)
                .fixedSize()
        }
        .position(textPos)
            // Effects for deleting
        .opacity(isDeleting ? 0 : (drawProgress > 0.5 ? 1.0 : 0.0))
        .scaleEffect(isDeleting ? 0.5 : (drawProgress > 0.5 ? 1.0 : 0.5))
            // Appears only after 50% of the edge is drawn
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: drawProgress > 0.5)
            // An arrow appears for vectors
        .animation(.spring(duration: 0.5, bounce: 0.60), value: edge.dataType == .vector)
            // Delete
        .animation(.easeOut(duration: 0.2), value: isDeleting)
    }
}


