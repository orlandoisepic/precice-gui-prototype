//
//  SimulationGameView 2.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 08.02.26.
//

import SwiftUI
import Combine

struct SimulationGameView: View {
    @StateObject private var engine = SimulationEngine()
    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Layers
                GameBackgroundView(engine: engine)
                
                ObstacleLayer(obstacles: engine.obstacles, height: geo.size.height)
                
                HeroView(
                    rotation: engine.rotationAngle,
                    scale: engine.implosionScale,
                    opacity: engine.implosionOpacity
                )
                .position(
                    x: 100,
                    y: geo.size.height - GameConfig.groundHeight - (GameConfig.heroSize / 2) + engine.heroY
                )
                
                GameHUD(engine: engine)
            }
            // Input and game loop
            .contentShape(Rectangle())
            .onTapGesture { engine.jump() }
            .focusable()
            .onKeyPress(.space) { engine.jump(); return .handled }
            .onReceive(timer) { _ in
                engine.update(in: geo.size)
            }
        }
    }
}
