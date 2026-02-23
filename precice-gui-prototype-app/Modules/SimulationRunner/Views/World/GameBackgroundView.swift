import SwiftUI
import Combine



struct GameBackgroundView: View {
    @ObservedObject var engine: SimulationEngine
    @StateObject private var particleEngine = BackgroundParticleEngine()
    
    var body: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)
                .ignoresSafeArea()
            
            ForEach(particleEngine.pulses) { pulse in
                Capsule()
                    .fill(
                        // Gradient for "meteor" pulse tail
                        LinearGradient(
                            colors: [
                                levelColor.opacity(0),
                                levelColor.opacity(pulse.opacity)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: pulse.length, height: 2)
                    .rotationEffect(pulse.angle)
                    .position(pulse.position)
            }
            
            RadialGradient(
                colors: [.clear, .black.opacity(0.1)],
                center: .center,
                startRadius: 200,
                endRadius: 600
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                Rectangle()
                    .fill(Material.ultraThin)
                    .frame(height: GameConfig.groundHeight)
                    .overlay(alignment: .top) {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(levelColor.opacity(0.5))
                            .shadow(color: levelColor, radius: 4)
                    }
            }
        }
    }
    
        // Color based on level
    var levelColor: Color {
        switch engine.currentOrder {
        case 1...2: return .cyan
        case 3: return .mint
        case 4: return .indigo
        case 5: return .purple
        default: return .red
        }
    }
}
