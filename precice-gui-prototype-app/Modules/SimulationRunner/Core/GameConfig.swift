//
//  GameConfig.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 08.02.26.
//


import SwiftUI
import Combine

struct GameConfig {
    static let gravity: CGFloat = 1.2
    static let jumpForce: CGFloat = -22.0
    static let groundHeight: CGFloat = 60
    static let heroSize: CGFloat = 60
    static let obstacleWidth: CGFloat = 30
    static let obstacleHeight: CGFloat = 75
    static let initialSpeed: Double = 8.0
    static let initialReqIterations: Int = 5
}


