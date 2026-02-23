    //
    //  BackgroundLayer.swift
    //  case-generate-app
    //
    //  Created by Orlando Ackermann on 06.02.26.
    //
import SwiftUI

struct BackgroundLayer: View {
    @EnvironmentObject var viewModel: GraphCanvasViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("showGrid") var showGrid: Bool = true
    
    @Binding var dragOffset: CGSize
    @Binding var canvasMousePosition: CGPoint
    
    var body: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)
                .ignoresSafeArea()
            
                // Grid
            if showGrid {
                InfiniteGridPattern(panOffset: currentPanOffset)
                    .stroke(gridColor, lineWidth: 2)
                    .transition(.opacity)
            }
            
        }
        .gesture(panGesture)
        .onContinuousHover { phase in
            if case .active(let location) = phase {
                self.canvasMousePosition = location
            }
        }
        .contextMenu {
            backgroundContextMenu
        }
        .onTapGesture {
            DispatchQueue.main.async {
                NSApp.keyWindow?.makeFirstResponder(nil)
            }
        }
    }
}
    // MARK: - Helpers
private extension BackgroundLayer {
    
    var gridColor: Color {
        themeManager.effectiveScheme == .dark ? .white.opacity(0.15) : .black.opacity(0.2)
    }
    
    var currentPanOffset: CGPoint {
        CGPoint(
            x: viewModel.panOffset.x + dragOffset.width,
            y: viewModel.panOffset.y + dragOffset.height
        )
    }
    
    var panGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                viewModel.panOffset.x += value.translation.width
                viewModel.panOffset.y += value.translation.height
                dragOffset = .zero
            }
    }
    
    @ViewBuilder
    var backgroundContextMenu: some View {
        let worldPos = CGPoint(
            x: canvasMousePosition.x - viewModel.panOffset.x,
            y: canvasMousePosition.y - viewModel.panOffset.y
        )
            // Add participant when right-clicking on the background
        Button("Add Participant Node") {
            viewModel.addParticipant(at: worldPos)
        }
    }
}
