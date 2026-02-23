//
//  ParticipantContextMenu.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 07.02.26.
//


import SwiftUI

struct ParticipantContextMenu: View {
    let currentDimensionality: ParticipantDimensionality?
    
    // Actions passed from parent
    var onAddPatch: () -> Void
    var onUpdateDimension: (ParticipantDimensionality?) -> Void
    var onDelete: () -> Void
    
    var body: some View {
        Button("Add patch") {
            onAddPatch()
        }
        
        Divider()
        
        Menu {
            Button("2D") {onUpdateDimension(.twoD)}
            Button("3D") {onUpdateDimension(.threeD)}
            Divider()
            Button("Default") {onUpdateDimension(nil)}
        } label: {
            Label("Set dimensionality", systemImage: "square.and.pencil")
        }
        
        Divider()

        Button(role: .destructive) {
            onDelete()
        } label: {
            Label("Remove participant", systemImage: "trash")
        }
    }
}
