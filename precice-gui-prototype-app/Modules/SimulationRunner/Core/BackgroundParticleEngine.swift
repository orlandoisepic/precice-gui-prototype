//
//  BackgroundParticleEngine.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 08.02.26.
//

import SwiftUI
import Combine
    // Background with "meteors"
class BackgroundParticleEngine: ObservableObject {
    @Published var pulses: [NetworkPulse] = []
    
    struct NetworkPulse: Identifiable {
        let id = UUID()
        var position: CGPoint
        let velocity: CGPoint
        let angle: Angle
        let length: CGFloat
        let opacity: Double
    }
    
    private var timer: Timer?
    
    init() {
        startAnimation()
    }
    
    func startAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateNetwork()
        }
    }
    
    func updateNetwork() {
            // 20 pulses
        if pulses.count < 20 {
            if Int.random(in: 0...3) == 0 {
                spawnPulse()
            }
        }
        
        for i in pulses.indices {
            pulses[i].position.x += pulses[i].velocity.x
            pulses[i].position.y += pulses[i].velocity.y
        }
        
        pulses.removeAll { pulse in
            pulse.position.x < -200 || pulse.position.x > 2000 ||
            pulse.position.y < -200 || pulse.position.y > 2000
        }
    }
    
    func spawnPulse() {
            // Hardcoded generic size for spawning to avoid passing GeometryProxy everywhere
        let w: CGFloat = 1000
        let h: CGFloat = 800
        
        let side = Int.random(in: 0...3)
        var start = CGPoint.zero
        var target = CGPoint.zero
        
            // Spawn from random borders
        switch side {
        case 0: // Top
            start = CGPoint(x: CGFloat.random(in: 0...w), y: -50)
            target = CGPoint(x: CGFloat.random(in: 0...w), y: h + 50)
        case 1: // Right
            start = CGPoint(x: w + 50, y: CGFloat.random(in: 0...h))
            target = CGPoint(x: -50, y: CGFloat.random(in: 0...h))
        case 2: // Bottom
            start = CGPoint(x: CGFloat.random(in: 0...w), y: h + 50)
            target = CGPoint(x: CGFloat.random(in: 0...w), y: -50)
        case 3: // Left
            start = CGPoint(x: -50, y: CGFloat.random(in: 0...h))
            target = CGPoint(x: w + 50, y: CGFloat.random(in: 0...h))
        default: break
        }
        
        let dx = target.x - start.x
        let dy = target.y - start.y
        let distance = sqrt(dx*dx + dy*dy)
        // Random constant speed
        let speed = CGFloat.random(in: 4...8)
        
        let vx = (dx / distance) * speed
        let vy = (dy / distance) * speed
        let angle = Angle(radians: atan2(dy, dx))
        
        pulses.append(NetworkPulse(
            position: start,
            velocity: CGPoint(x: vx, y: vy),
            angle: angle,
            length: CGFloat.random(in: 80...200),
            opacity: Double.random(in: 0.3...0.7)
        ))
    }
}
