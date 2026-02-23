    //
    //  RunButton.swift
    //  case-generate-app
    //
    //  Created by Orlando Ackermann on 09.02.26.
    //


import SwiftUI


struct RunButton: View {
    
    @State private var isHovering = false
    @State private var isPressed = false
    @StateObject var filePreviewViewModel: FilePreviewViewModel
    @ObservedObject var graphCanvasViewModel: GraphCanvasViewModel
    
    var topologyPath: URL?
    
    var body: some View {
        Button(action: performRun) {
            ZStack {
                    // Show a wheel instead when it is running
                if (graphCanvasViewModel.generationState == .running) {
                    ProgressView()
                        .controlSize(.small)
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                } else {
                    Image(systemName: "play.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.green)
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                        .tint(.green)
                }
            }
            .frame(width: 28, height: 28)
            .background {
                Circle()
                    .fill(isHovering ? Color.primary.opacity(0.1) : Color.clear)
            }
            .scaleEffect(isPressed ? 0.8 :  1.0)
        }
        .buttonStyle(.plain)
        .animation(
            .easeInOut(duration: 0.2),
            value: graphCanvasViewModel.generationState
        )
        .onHover { hover in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hover
            }
        }
        .cornerRadius(14)
        .disabled(graphCanvasViewModel.generationState == .running)
        .help("Run case-generate")
        .keyboardShortcut("r", modifiers: .command)
    }
    
    private func performRun() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isPressed = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // wrapping this in an animation would cause lag
            isPressed = false
            if topologyPath != nil {
                // saving the file here also causes lag
                graphCanvasViewModel.runSimulation(topologyPath: topologyPath)
            } else {
                graphCanvasViewModel.runSimulation()
            }
        }
    }
}
