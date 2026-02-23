    //
    //  EdgeHitShape.swift
    //  case-generate-app
    //
    //  Created by Orlando Ackermann on 08.02.26.
    //

import SwiftUI

struct EdgeHitShape: Shape {
    var start: CGPoint
    var end: CGPoint
    var control: CGPoint
    
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
        var path = Path()
        path.move(to: start)
        path.addQuadCurve(to: end, control: control)
        return path
    }
}
