    //
    //  GraphThumbnail.swift
    //  preCICEUtilityApp
    //
    //  Created by Orlando Ackermann on 10.02.26.
    //

import SwiftUI

struct GraphThumbnail: View {
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("fancyAnimationsEnabled") var fancyAnimationsEnabled: Bool = true
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                
                let startPoint = CGPoint(x: geo.size.width * 0.25, y: geo.size.height * 0.7)
                let endPoint = CGPoint(x: geo.size.width * 0.75, y: geo.size.height * 0.4)
                    // Midpoint
                let controlPoint = CGPoint(
                    x: (startPoint.x + endPoint.x) / 2,
                    y: (startPoint.y + endPoint.y) / 2
                )
                    // B. Calculate Angle for Patch Placement
                    // This ensures the patches "look" at each other perfectly
                let dx = endPoint.x - startPoint.x
                let dy = endPoint.y - startPoint.y
                let angle = atan2(dy, dx)
                
                let radius: CGFloat = 22
                
                let patchOffsetX = cos(angle) * radius
                let patchOffsetY = sin(angle) * radius
                
                
                let startPatchPosition = CGPoint(
                    x: startPoint.x + patchOffsetX,
                    y: startPoint.y + patchOffsetY
                )
                let endPatchPosition = CGPoint(
                    x: endPoint.x + patchOffsetX,
                    y: endPoint.y + patchOffsetY
                )
                
                ThumbnailPath(start: startPatchPosition, end: endPatchPosition, control: controlPoint)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                
                    // The Animated Pulse
                if fancyAnimationsEnabled {
                    ThumbnailPulse(start: CGPoint(x: startPoint.x + patchOffsetX, y: startPoint.y + patchOffsetY), end: endPatchPosition, control: controlPoint)
                }

                
                ZStack {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.primary)
                }
                .position(controlPoint)
                .offset(y: -12)
                
                ThumbnailNode(icon: "cube.fill", patchOffset: CGSize(width: patchOffsetX, height: patchOffsetY))
                    .position(startPoint)
                
                ThumbnailNode(icon: "cube.fill", patchOffset: CGSize(width: -patchOffsetX, height: -patchOffsetY))
                    .position(endPoint)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

    // MARK: - Subcomponents

    /// A simplified version of EdgePulse
private struct ThumbnailPulse: View {
    let start: CGPoint
    let end: CGPoint
    let control: CGPoint
    
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var phase: CGFloat = 0.0
    
    var coreColor: Color {
        themeManager.effectiveScheme == .dark ? .white : .white
    }
    
    var glowColor: Color {
        themeManager.accentColor.color
    }
    
    var body: some View {
        ThumbnailPath(start: start, end: end, control: control)
                // "Grow" from start to end
            .trim(from: 0, to: phase + 0.05)
            .stroke(
                coreColor,
                style: StrokeStyle(lineWidth: themeManager.effectiveScheme == .dark ? 2.5 : 1.5, lineCap: .round)
            )
            .shadow(color: glowColor, radius: 5)
                // Fade out
            .opacity(1.0 - phase)
            .onAppear {
                runPulseAnimation()
            }
    }
    private func runPulseAnimation() {
        phase = -0.1
        
        withAnimation(.easeInOut(duration: 2.5)) {
            phase = 1.0
        }
            // Run a recursive loop after the pause duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            runPulseAnimation()
        }
    }
}

    ///  Path
private struct ThumbnailPath: Shape {
    var start: CGPoint
    var end: CGPoint
    var control: CGPoint
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        return path
    }
}

    /// Dummy participant with patches
private struct ThumbnailNode: View {
    let icon: String
    let patchOffset: CGSize
    @EnvironmentObject var themeManager: ThemeManager
    
    var nodeColor: Color {
        themeManager.effectiveScheme == .dark ? Color.blue : Color.blue.mix(with: .white, by: 0.4)
    }
    
    var patchColor: Color {
        themeManager.effectiveScheme == .dark ? .orange : Color.orange.opacity(0.8)
    }
    
    var body: some View {
        ZStack {
                // Node Body
            Circle()
                .fill(nodeColor.gradient)
                .frame(width: 44, height: 44)
                .overlay(
                    Circle().stroke(nodeColor.opacity(0.5), lineWidth: 2)
                )
                .shadow(radius: 4)
            
                // Icon
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(.white.opacity(0.9))
                
                // Patch
            Circle()
                .fill(patchColor.gradient)
                .frame(width: 12, height: 12)
                .overlay(Circle().stroke(.white, lineWidth: 1.5))
                .offset(patchOffset)
        }
    }
}

