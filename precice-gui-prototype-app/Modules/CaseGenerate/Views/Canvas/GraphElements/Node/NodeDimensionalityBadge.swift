import SwiftUI

struct NodeDimensionalityBadge: View {
    let dimensionality: ParticipantDimensionality?
    
    var body: some View {
        if let dim = dimensionality {
                // Dimensionality is given
            Text(dim.label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(dim.color)
                        .shadow(radius: 1)
                )
                .overlay(
                    Capsule().stroke(Color.white, lineWidth: 1)
                )
        } else {
                // Dimensionality is not given
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(.yellow)
                .background(Circle().fill(Color.black))
                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
                .shadow(radius: 2)
        }
    }
}
