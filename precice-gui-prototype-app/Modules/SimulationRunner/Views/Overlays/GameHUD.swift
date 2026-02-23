//
//  GameHUD.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 08.02.26.
//
import SwiftUI
import Combine

struct GameHUD: View {
    @ObservedObject var engine: SimulationEngine
    
    var body: some View {
        VStack {
            // Top bar with stats
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("ORDER \(engine.currentOrder)")
                        .font(.system(.title3, design: .monospaced))
                        .fontWeight(.bold)
                    Text("Speed: \(String(format: "%.1f", engine.gameSpeed))x")
                        .font(.caption).foregroundStyle(.secondary)
                }

                Text("BEST: \(engine.maxOrder)")
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 8)
                
                Spacer()
                
                Text("Total Steps: \(engine.totalSteps)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("TO CONVERGENCE")
                        .font(.caption).fontWeight(.bold).foregroundStyle(.secondary)
                    Text("\(max(0, engine.requiredIterations - engine.progressInOrder))")
                        .font(.system(.largeTitle, design: .monospaced))
                        .fontWeight(.heavy).foregroundStyle(Color.blue)
                }
            }
            .padding()
            
                // Show message for new level
            if engine.showOrderUpFlash {
                Text("ACCURACY INCREASED!")
                    .font(.largeTitle.weight(.black))
                    .foregroundStyle(.green)
                    .shadow(color: .green.opacity(0.5), radius: 10)
                    .transition(.scale.combined(with: .opacity))
            }
            
            Spacer()
            
            // Overlays
            if !engine.isPlaying && !engine.isGameOver {
                StartMessage()
            }
            
            if engine.isGameOver {
                GameOverMessage(
                    order: engine.currentOrder,
                    remaining: engine.requiredIterations - engine.progressInOrder,
                    isNewRecord: engine.isNewRecord,
                    onRestart: engine.resetGame
                )
            }
        }
    }
}
