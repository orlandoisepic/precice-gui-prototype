//
//  GameOverMessage.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 08.02.26.
//


import SwiftUI

struct GameOverMessage: View {
    let order: Int
    let remaining: Int
    let isNewRecord: Bool
    let onRestart: () -> Void
    
    var body: some View {
        VStack(spacing: -20) { // Negative spacing to overlap slightly or keep tight
            

            if isNewRecord {
                HStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 16, weight: .bold))
                    
                    Text("NEW BEST CONVERGENCE")
                        .font(.system(.subheadline, design: .monospaced))
                        .fontWeight(.bold)
                }
                .foregroundStyle(Color.black.opacity(0.8))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background{
                    Capsule()
                        .fill(LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .shadow(color: .orange.opacity(0.5), radius: 10, y: 5)
                }
                .zIndex(1) // Ensure it sits on top
                .transition(.move(edge: .top).combined(with: .opacity))
                .offset(y: -10) // Float slightly above the card
            }
                // Death
            VStack(spacing: 16) {
                // Icon
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50))
                    .symbolEffect(.pulse)
                    .foregroundStyle(.orange)
                
                // Title
                Text("Diverged at Order \(order)")
                    .font(.largeTitle.weight(.heavy))
                    .foregroundStyle(.primary)
                
                // Details Details
                VStack(spacing: 4) {
                    Text("Solver instability detected")
                        .font(.body.weight(.semibold))
                    
                    Text("with \(remaining) iterations remaining.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if isNewRecord {
                        // Different accent color depending on success
                    Button(action: onRestart) {
                        Text("Re-Mesh and Restart")
                            .font(.body.weight(.bold))
                            .foregroundStyle(Color.black.opacity(0.8))
                            .padding(.horizontal, 24) // A bit wider for the button
                            .padding(.vertical, 12)
                            .background{
                                Capsule()
                                    .fill(LinearGradient(
                                        colors: [Color.yellow, Color.orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .shadow(color: .orange.opacity(0.5), radius: 10, y: 5)
                            }
                    }
                    .buttonStyle(.plain) 
                    .padding(.top, 10)
                    
                } else {
                    Button("Re-Mesh and Restart") {
                        onRestart()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.top, 10)
                }
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color.red.opacity(0.3), lineWidth: 1)
            )
            .shadow(radius: 30)
            .padding(.bottom, 50)
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isNewRecord)
    }
}
