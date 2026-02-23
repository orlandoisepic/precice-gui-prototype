//
//  HeroView.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 08.02.26.
//

import SwiftUI

struct HeroView: View {
    let rotation: Double
    let scale: CGFloat
    let opacity: Double
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.gradient)
                .shadow(radius: 4)
            
            Image(systemName: "cube.fill")
                .resizable()
                .padding(20)
                .foregroundStyle(.white)
        }
        .frame(width: GameConfig.heroSize, height: GameConfig.heroSize)
        .rotationEffect(.degrees(rotation))
        .scaleEffect(scale)
        .opacity(opacity)
    }
}
