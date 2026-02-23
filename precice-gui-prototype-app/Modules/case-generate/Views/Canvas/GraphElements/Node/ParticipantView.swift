import SwiftUI

struct ParticipantNodeView: View {
    @Binding var participant: Participant
    
    @ObservedObject var viewModel: GraphCanvasViewModel
    @State var lastMousePosition: CGPoint = .zero
    @EnvironmentObject var themeManager: ThemeManager
    
    @State var isDeleting = false
    @State private var badgeTrigger = false
    
    @AppStorage("fancyAnimationsEnabled") private var fancyAnimationsEnabled: Bool = true

        // Slighly lighter blue for light mode
    var nodeColor: Color {
        if themeManager.effectiveScheme == .dark {
            return Color.blue
        } else {
            return Color.blue.mix(with: .white, by: 0.4)
        }
    }
        // White shadow in case of dark mode else dark shadow
    var shadowColor: Color {
        if themeManager.effectiveScheme == .dark {
            return .white
        }
        else {
            return .black
        }
    }
    // How long the "death" effect takes
    var delay: Double {fancyAnimationsEnabled ? 0.4 : 0.1}
    
    var body: some View {
        
        
        ZStack {
            Circle()
                .fill(nodeColor.gradient)
                .overlay(
                    Circle().stroke(nodeColor.opacity(0.5), lineWidth: 2)
                )
                .shadow(radius: 5)
                .onContinuousHover { phase in
                    if case .active(let location) = phase {
                        self.lastMousePosition = location
                    }
                }
                .overlay(alignment: .topTrailing) {
                    // Node dimensionality 
                    NodeDimensionalityBadge(dimensionality: participant.dimensionality)
                        .offset(x: 5, y: -5)
                        .modifier(PopupAnimation(response: 0.4, damping: 0.5))
                        .id("Badge-\(participant.dimensionality?.hashValue ?? 0)")
                }
            
                // Patches
            PatchRing(patches: $participant.patches, parentID: participant.id, viewModel: viewModel)
                // The icon and solver name
            NodeInterior(solver: $participant.solver)
                // Name tag
            NodeNameTag(name: $participant.name, nodeRadius: viewModel.nodeRadius)
        }
        .frame(
            // Slighly larger hit area
            width: viewModel.nodeRadius * 2 + 5,
            height: viewModel.nodeRadius * 2 + 5
        )
        .modifier(PopupAnimation(response: 0.35, damping: 0.45))
            // Implosion delete effect
        .scaleEffect(isDeleting ? (fancyAnimationsEnabled ? 0.01 : 0.95) : 1.0)
        .rotationEffect(Angle(degrees: (isDeleting && fancyAnimationsEnabled) ? 360 : 0))
        .opacity(isDeleting ? 0.0 : 1.0)
        .animation(.easeInOut(duration: delay), value: isDeleting)
        .onChange(of: viewModel.dyingParticipantIDs) { _, dyingSet in
            if dyingSet.contains(participant.id) && !isDeleting {
                withAnimation { isDeleting = true }
            }
        }
        
        .contextMenu {
            ParticipantContextMenu(
                currentDimensionality: participant.dimensionality,
                onAddPatch: {addPatchAtMouseLocation()},
                onUpdateDimension: {dim in updateDimension(dim)},
                onDelete: {handleDeletion()}
            )
        }
    }
}
