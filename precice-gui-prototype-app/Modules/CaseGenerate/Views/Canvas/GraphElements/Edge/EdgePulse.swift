//
//  EdgePulse.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 07.02.26.
//
import SwiftUI

struct EdgePulse: View {
    let start: CGPoint
    let end: CGPoint
    let control: CGPoint
    let strength: EdgeStrength
    
    @EnvironmentObject var themeManager: ThemeManager
    
        // Duration of pulse / pause between pulses
    var basePulseDuration: Double { strength == .strong ? 1.5 : 2.0 }
    var basePauseDuration: Double { strength == .strong ? 1.5 : 2.0 }
    
    
    var coreColor: Color {
        if themeManager.effectiveScheme == .dark {
            return .white
        } else {
            return themeManager.accentColor.color
        }
    }
    
    var glowColor: Color {
        return themeManager.accentColor.color
    }
    
    var body: some View {
            // Timeline is needed to avoid "jumps" in pulse progress when moving a node
        TimelineView(.animation) { timeline in
            let now = timeline.date.timeIntervalSinceReferenceDate
            let cycleLength = basePulseDuration + basePauseDuration
            let cycleTime = now.truncatingRemainder(dividingBy: cycleLength)
            
                // Calculate phase purely based on the absolute clock
            let phase: CGFloat = cycleTime < basePulseDuration
            ? CGFloat(cycleTime / basePulseDuration)
            : 1.0
            
                // Draw the same path as the edge, but with the pulse
            DrawQuadPath(start: start, end: end, control: control)
                .trim(from: 0, to: phase + 0.05)
                .stroke(
                    coreColor,
                    style: StrokeStyle(lineWidth: strength == .strong ? 5.0 : 2.5, lineCap: .round)
                )
                .shadow(color: glowColor, radius: 5)
                .opacity(1.0 - phase)
                .allowsHitTesting(false)
        }
    }
}
