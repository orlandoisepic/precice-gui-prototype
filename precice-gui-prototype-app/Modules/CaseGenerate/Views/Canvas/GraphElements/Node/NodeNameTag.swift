//
//  NodeNameTag.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 07.02.26.
//
import SwiftUI

struct NodeNameTag: View {
    @Binding var name: String
    let nodeRadius: CGFloat
    
    var body: some View {
        TextField("Name", text: $name)
            .textFieldStyle(.plain)
            .multilineTextAlignment(.center)
            .background(.ultraThinMaterial)
            .cornerRadius(8)
            .padding(4)
            .frame(width: max(60, 12 + CGFloat(name.count) * 7))
            .offset(y: nodeRadius + 20)
    }
}
