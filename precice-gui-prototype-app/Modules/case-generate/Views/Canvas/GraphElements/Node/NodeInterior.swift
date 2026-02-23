//
//  NodeInterior.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 07.02.26.
//
import SwiftUI

struct NodeInterior: View {
    @Binding var solver: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: "cube.fill")
                .resizable()
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .padding(.bottom, 4)
                // Textfield for solver name
            TextField("Solver", text: $solver)
                .textFieldStyle(.plain)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .frame(width: max(min(100, 12 + CGFloat(solver.count) * 7), 60))
                .background(Color.black.opacity(0.2))
                .cornerRadius(8)
        }
    }
}
