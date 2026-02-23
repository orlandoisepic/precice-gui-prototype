    //
    //  SimulationEngine.swift
    //  case-generate-app
    //
    //  Created by Orlando Ackermann on 08.02.26.
    //
import SwiftUI
import Combine

class SimulationEngine: ObservableObject {
        // Game State
    @Published var isPlaying = false
    @Published var isGameOver = false
    
    @Published var currentOrder = 1
    @Published var progressInOrder = 0
    @Published var requiredIterations = GameConfig.initialReqIterations
    @Published var gameSpeed = GameConfig.initialSpeed
    
        // Score State
    @Published var totalSteps = 0 // Just for current run stats
    @Published var maxOrder = UserDefaults.standard.integer(forKey: "SimRunnerMaxOrder")
    @Published var isNewRecord = false
    
        // Physics State
    @Published var heroY: CGFloat = 0
    @Published var heroVelocity: CGFloat = 0
    @Published var rotationAngle: Double = 0
    @Published var implosionScale: CGFloat = 1.0
    @Published var implosionOpacity: Double = 1.0
    @Published var showOrderUpFlash = false
    
    private var isWarmingUp = true
    
    init() {
            // No input is possible at the beginning to avoid accidental starts
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isWarmingUp = false
        }
    }
    
    @Published var obstacles: [Obstacle] = []
    
    func jump() {
        if isWarmingUp { return }
        
        DispatchQueue.main.async {
            if !self.isPlaying {
                self.resetGame()
                return
            }
                // Jump if on floor
            if self.heroY == 0 {
                self.heroVelocity = GameConfig.jumpForce
            }
        }
    }
    
    func resetGame() {
        isGameOver = false
        isPlaying = true
        currentOrder = 1
        progressInOrder = 0
        requiredIterations = GameConfig.initialReqIterations
        gameSpeed = GameConfig.initialSpeed
        heroY = 0
        heroVelocity = 0
        rotationAngle = 0
        implosionScale = 1.0
        implosionOpacity = 1.0
        obstacles = []
    }
    
        /// Game loop
    func update(in size: CGSize) {
        guard isPlaying else { return }
        
        if isGameOver {
            animateImplosion()
            return
        }
        
        applyPhysics()
        animateRolling()
        manageObstacles(in: size)
        checkCollisions(in: size)
    }
    
    private func applyPhysics() {
        if heroY < 0 || heroVelocity < 0 {
            heroVelocity += GameConfig.gravity
            heroY += heroVelocity
            if heroY > 0 { heroY = 0; heroVelocity = 0 }
        }
    }
    
    private func animateRolling() {
        if heroY == 0 {
                // Math for realistic rolling
            rotationAngle += (
                gameSpeed / (Double.pi * GameConfig.heroSize)
            ) * 360
        } else {
            rotationAngle += 5 // Slower spin in air
        }
    }
        // Death
    private func animateImplosion() {
        if implosionScale > 0.01 {
            implosionScale *= 0.85
            implosionOpacity *= 0.85
        }
    }
    
    private func manageObstacles(in size: CGSize) {
            // Gap between obstacles
        let minGap: CGFloat = 300
        if obstacles.isEmpty || (obstacles.last!.x < size.width - minGap) {
            if Int.random(in: 0...50) == 0 { // 2% chance per frame
                                             
                let newObstacle = Obstacle(
                    x: size.width + 50,
                        // Peak is somewhere in the middle 20-80%
                    heightFactor: CGFloat.random(in: 0.85...1.35),
                    widthFactor: CGFloat.random(in: 0.8...1.2),
                    tipOffset: CGFloat.random(in: -0.2...0.2)
                )
                obstacles.append(newObstacle)
            }
        }
            // Move obstacles
        for i in obstacles.indices {
            obstacles[i].x -= gameSpeed
        }
            // Remove obstacles
        if let first = obstacles.first, first.x < -50 {
            obstacles.removeFirst()
            progressOrder()
        }
    }
    
    private func progressOrder() {
        progressInOrder += 1
        totalSteps += 1
        
        if progressInOrder >= requiredIterations {
            increaseOrder()
        }
        
        if currentOrder > maxOrder {
            maxOrder = currentOrder
            isNewRecord = true
            UserDefaults.standard.set(maxOrder, forKey: "SimRunnerMaxOrder")
        }
    }
        // Hitbox calculations for obstacles
    private func checkCollisions(in size: CGSize) {
            
        let groundY = size.height - GameConfig.groundHeight
        
        let heroFrame = CGRect(
            x: 100 - GameConfig.heroSize/2 + 6,
            y: groundY - GameConfig.heroSize + heroY + 6,
            width: GameConfig.heroSize - 12,
            height: GameConfig.heroSize - 12
        )
        
        for obstacle in obstacles {
            let spikeFrame = CGRect(
                x: obstacle.x - GameConfig.obstacleWidth/2 + 8,
                y: groundY - GameConfig.obstacleHeight + 15,
                width: GameConfig.obstacleWidth - 16,
                height: GameConfig.obstacleHeight - 20
            )
            
            if heroFrame.intersects(spikeFrame) {
                isGameOver = true
            }
        }
    }
    private func increaseOrder() {
        currentOrder += 1
        progressInOrder = 0
        requiredIterations += (requiredIterations < 25 ? 5 : 0)
        gameSpeed += 1.5
        
        showOrderUpFlash = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.showOrderUpFlash = false
        }
    }
}
