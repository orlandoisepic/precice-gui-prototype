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
    func path(in rect: CGRect) -> Path {
        Path { p in p.move(to: start); p.addQuadCurve(to: end, control: control) }
    }
}
