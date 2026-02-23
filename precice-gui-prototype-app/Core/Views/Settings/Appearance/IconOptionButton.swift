    //
    //  IconOptionButton.swift
    //  case-generate-app
    //
    //  Created by Orlando Ackermann on 06.02.26.
    //

import SwiftUI

    // Helper for the Icon Button
struct IconOptionButton: View {
    let imageName: String
    let assetName: String
    let selectedName: String
    let action: () -> Void
    
    var isSelected: Bool { selectedName == assetName }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                    // The Icon Image
                Image(nsImage: NSImage(named: imageName) ?? NSImage(named: "AppIcon")!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                
                    // Selection Dot
                if isSelected {
                    Circle().fill(Color.blue).frame(width: 4, height: 4)
                } else {
                    Circle().fill(Color.clear).frame(width: 4, height: 4)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                .padding(-5)
        )
        .animation(.snappy, value: selectedName)
    }
}
