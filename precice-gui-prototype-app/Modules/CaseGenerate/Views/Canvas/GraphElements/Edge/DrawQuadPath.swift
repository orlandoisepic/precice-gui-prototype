//
//  DrawQuadPath.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 07.02.26.
//
import SwiftUI

// Draw a path for the given coordinates
struct DrawQuadPath: Shape {
    var start: CGPoint
    var end: CGPoint
    var control: CGPoint
    
        // Allow animations such as spring
    var animatableData: AnimatablePair<CGPoint.AnimatableData, AnimatablePair<CGPoint.AnimatableData, CGPoint.AnimatableData>> {
        get {
            AnimatablePair(start.animatableData, AnimatablePair(end.animatableData, control.animatableData))
        }
        set {
            start.animatableData = newValue.first
            end.animatableData = newValue.second.first
            control.animatableData = newValue.second.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { p in p.move(to: start); p.addQuadCurve(to: end, control: control) }
    }
}
