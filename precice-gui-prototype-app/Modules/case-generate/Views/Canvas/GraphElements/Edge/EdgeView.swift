import SwiftUI

struct EdgeView: View {
    @Binding var edge: Edge
    @ObservedObject var viewModel: GraphCanvasViewModel
    
    @AppStorage(
        "fancyAnimationsEnabled"
    ) private var fancyAnimationsEnabled: Bool = true
    
    @State private var drawProgress: CGFloat = 0.0
    @State private var isDeleting = false
    
    private var delay: Double {
        if fancyAnimationsEnabled {
            return 0.4
        }
        else {
            return 0.1
        }
    }
    
    var body: some View {
        Group {
            if let data = resolvedEdgeData {
                renderEdgeStack(
                    start: data.start,
                    end: data.end,
                    curve: data.curve
                )
            }
        }    // Lifecycle
        .onAppear {
            withAnimation(.easeInOut(duration: delay)) { drawProgress = 1.0 }
        }
        .onChange(of: viewModel.dyingEdgeIDs) { _, newDyingSet in
            if newDyingSet.contains(edge.id) && !isDeleting {
                withAnimation { isDeleting = true }
            }
        }
    }
    
    @ViewBuilder
    private func renderEdgeStack(start: CGPoint, end: CGPoint, curve: CurveGeometry) -> some View {
        ZStack {
                // A. THE INVISIBLE SENSOR (Hitbox & Menu)
            EdgeSensor(
                start: start, end: end, control: curve.controlPoint,
                drawProgress: drawProgress,
                edge: $edge,
                viewModel: viewModel,
                triggerBurnout: { withAnimation { isDeleting = true } },
                isFancy: fancyAnimationsEnabled
            )
            
            EdgeVisuals(
                start: start, end: end, control: curve.controlPoint,
                strength: edge.strength,
                drawProgress: drawProgress,
                isDeleting: isDeleting,
                isFancy: fancyAnimationsEnabled
            )
                
            if (fancyAnimationsEnabled && !isDeleting) {
                EdgePulse(
                    start: start,
                    end: end,
                    control: curve.controlPoint,
                    strength: edge.strength
                )
                    // Update if strength changes
                .id(edge.strength)
            }
            
            EdgeArrow(
                start: start, end: end, control: curve.controlPoint,
                strength: edge.strength,
                drawProgress: drawProgress,
                isDeleting: isDeleting,
                isFancy: fancyAnimationsEnabled
            )
            
            EdgeLabel(
                start: start, end: end, control: curve.controlPoint,
                perpVector: curve.perpVector,
                edge: $edge,
                drawProgress: drawProgress,
                isDeleting: isDeleting
            )
        }
        .animation(.easeOut(duration: delay), value: isDeleting)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}
