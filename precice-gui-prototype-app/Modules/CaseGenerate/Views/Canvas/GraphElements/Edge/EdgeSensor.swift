    //
    //  EdgeSensor.swift
    //  case-generate-app
    //
    //  Created by Orlando Ackermann on 07.02.26.
    //

import SwiftUI

struct EdgeSensor: View {
    let start: CGPoint
    let end: CGPoint
    let control: CGPoint
    let drawProgress: CGFloat
    
    @Binding var edge: Edge
    @ObservedObject var viewModel: GraphCanvasViewModel
    
    let triggerBurnout: () -> Void
    let isFancy: Bool
    
    var body: some View {
        // Time to draw the edge
        let delay = isFancy ? 0.4 : 0.1
        
        EdgeHitShape(start: start, end: end, control: control)
            // Hitbox grows with line
            .trim(from: 0, to: drawProgress)
        
            // A wider hitbox
            .stroke(
                Color.white.opacity(0.001),
                style: StrokeStyle(lineWidth: 40, lineCap: .round, lineJoin: .round)
            )
            .contentShape(EdgeHitShape(start: start, end: end, control: control).stroke(lineWidth: 40))
        
            .contextMenu {
                // TODO Maybe an indicator of some sorts for what is selected?
                Menu("Set data-type") {
                    Button("Vector") { edge.dataType = .vector }
                    Button("Scalar") { edge.dataType = .scalar }
                    Button("Default") { edge.dataType = nil }
                }
                Divider()
                Menu("Set exchange-type") {
                    Button("Strong") { edge.strength = .strong }
                    Button("Weak") { edge.strength = .weak }
                }
                Divider()
                Button(role: .destructive) {
                    NSApp.keyWindow?.makeFirstResponder(nil)
                    triggerBurnout()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        viewModel.edges.removeAll(where: { $0.id == edge.id })
                    }
                } label: {
                    Label("Remove exchange", systemImage: "trash")
                }
            }
    }
}
