    //
    //  ObstacleLayer.swift
    //  case-generate-app
    //
    //  Created by Orlando Ackermann on 08.02.26.
    //

import SwiftUI
struct ObstacleLayer: View {
    let obstacles: [Obstacle]
    let height: CGFloat
    
    var body: some View {
        ForEach(obstacles) { obstacle in
            ErrorSpikeShape(tipOffset: obstacle.tipOffset)
                .fill(LinearGradient(
                    colors: [.red, .orange],
                    startPoint: .bottom,
                    endPoint: .top
                ))
                .frame(
                    width: GameConfig.obstacleWidth * obstacle.widthFactor,
                    height: GameConfig.obstacleHeight * obstacle.heightFactor
                )
                .position(
                    x: obstacle.x,
                    y: height - GameConfig.groundHeight - (GameConfig.obstacleHeight * obstacle.heightFactor / 2)
                )
        }
    }
}
