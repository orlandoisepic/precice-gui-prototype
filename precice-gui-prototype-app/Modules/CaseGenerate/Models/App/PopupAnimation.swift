    //
    //  PopupAnimation.swift
    //  case-generate-app
    
    //  Created by Orlando Ackermann on 06.02.26.
    //
import SwiftUI

    // A helper modifier to make anything "Pop" in when created
struct PopupAnimation: ViewModifier {
    @State private var isVisible = false
    
    // Response: Speed (smaller means stiffer / faster); damping: Bounce (smaller means bouncier)
    var response: Double = 0.4
    var damping: Double = 0.4

    func body(content: Content) -> some View {
        content
            // 1. Start invisible and tiny
            .scaleEffect(isVisible ? 1.0 : 0.001)
            .opacity(isVisible ? 1.0 : 0.0)
            // 2. Animate immediately when added to the screen
            .onAppear {
                    // We use the simplest possible spring to avoid transaction conflicts
                withAnimation(.spring(response: response, dampingFraction: damping)) {
                    isVisible = true
                }
            }
    }
}
