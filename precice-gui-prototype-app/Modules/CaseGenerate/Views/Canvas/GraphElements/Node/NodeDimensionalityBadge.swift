import SwiftUI

struct NodeDimensionalityBadge: View {
    let dimensionality: ParticipantDimensionality?
    @ObservedObject var viewModel: GraphCanvasViewModel
    
        // This remembers the layout footprint so the ZStack never shrinks and slides when dimensionality becomes nil
    @State private var ghostLabel: String = "2D"
    @State private var ghostColor: Color = .blue
    
    var body: some View {
        let diameter = viewModel.participantDimensionalityBadgeRadius * 2
        let warningDiameter = diameter * 0.8
        
        let label = dimensionality?.label ?? ghostLabel
        let color = dimensionality?.color ?? ghostColor
        
        ZStack {
                // Dimensionality not given
            Image(systemName: "exclamationmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: warningDiameter, height: warningDiameter)
                .foregroundColor(.yellow)
                .background(Circle().fill(Color.black))
                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
                .shadow(radius: 2)
                .frame(minWidth: diameter, minHeight: diameter)
                // Visible only if dimensionality is not given
                .opacity(dimensionality == nil ? 1.0 : 0.0)
                .scaleEffect(dimensionality == nil ? 1.0 : 0.5)
            
                // Dimensionality given
            Text(label)
                .font(.system(size: viewModel.participantDimensionalityBadgeRadius * 1.2, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, viewModel.participantDimensionalityBadgeRadius * 0.5)
                .frame(height: diameter)
                .background(
                    Capsule().fill(color).shadow(radius: 1)
                )
                .overlay(
                    Capsule().stroke(Color.white, lineWidth: 1)
                )
                // Visible if dimensionality is given
                .opacity(dimensionality != nil ? 1.0 : 0.0)
                .scaleEffect(dimensionality != nil ? 1.0 : 0.5)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: dimensionality)
            // Keep the ghost state updated with the real data
        .onAppear {
            if let dim = dimensionality {
                ghostLabel = dim.label
                ghostColor = dim.color
            }
        }
        .onChange(of: dimensionality) { _, newValue in
            if let newDim = newValue {
                ghostLabel = newDim.label
                ghostColor = newDim.color
            }
        }
    }
}
