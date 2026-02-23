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
    
    @State private var phase: CGFloat = 0.0
    @EnvironmentObject var themeManager: ThemeManager
    
    
    var coreColor: Color {
        if themeManager.effectiveScheme == .dark {
            return .white
        }
        else {
            return themeManager.accentColor.color
        }
    }
    
    var glowColor: Color {
            // In Dark mode, the white core needs a colored glow to look good
            // In Light mode, we use the accent color for the shadow too
        return themeManager.accentColor.color
    }
    
    var basePulseDuration: Double {
        switch strength {
        case .strong:
            return 1.5
        case .weak:
            return 2.0
        }
    }
    
    var basePauseDuration: Double {
        switch strength {
        case .strong:
            return 1.5
        case .weak:
            return 2.0
        }
    }
    
    var body: some View {
        
        DrawQuadPath(start: start, end: end, control: control)
            .trim(from: 0, to: phase + 0.05)
            .stroke(
                coreColor,
                style: StrokeStyle(lineWidth: strength == .strong ? 5.0 : 2.5, lineCap: .round)
            )
            .shadow(color: glowColor, radius: 5)
            .opacity(1.0 - phase)
            .allowsHitTesting(false)
            .onAppear {
                runPulseAnimation()
            }
    }
    
    func runPulseAnimation() {
        // Duration of the pulse depends on the strength
        let randomPulse = Double.random(in: -0.1...0.1)
        let randomPause = Double.random(in: -0.15...0.15)
        let actualPulseDuration = max(0.1, basePulseDuration + randomPulse)
        let actualPauseDuration = max(0.1, basePauseDuration + randomPause)
        
        phase = -0.1
        
        withAnimation(.easeInOut(duration: actualPulseDuration)) {
            phase = 1.0
        }
        // Run a recursive loop after the pause duration
        DispatchQueue.main.asyncAfter(deadline: .now() + actualPulseDuration + actualPauseDuration) {
            runPulseAnimation()
        }
    }
}
