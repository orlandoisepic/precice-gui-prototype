//
//  StartMessage.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 08.02.26.
//

import SwiftUI

struct StartMessage: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "play.circle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.blue)
            Text("INITIALIZE SOLVER")
                .font(.headline)
            Text("Press Space to jump and avoid error spikes")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(30)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding(.bottom, 100)
    }
}
