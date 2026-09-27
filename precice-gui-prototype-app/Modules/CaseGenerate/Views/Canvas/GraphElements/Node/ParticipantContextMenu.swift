//
//  ParticipantContextMenu.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 07.02.26.
//


import SwiftUI

struct ParticipantContextMenu: View {
    // Actions passed from parent
    var onAddLocationNode: (LocationType) -> Void
    var onUpdateDimension: (ParticipantDimensionality?) -> Void
    var onDelete: () -> Void
    
    var body: some View {
        // Menu to add volume node
        Menu {
            Button("Surface") { onAddLocationNode(.surface) }
            Button("Volume") { onAddLocationNode(.volume) }
            Divider()
            // The default type is surface
            Button("Default") { onAddLocationNode(.surface) }
        } label: {
            Label("Add location...", systemImage: "plus.circle")
        }
        
        Divider()
        
        Menu {
            Button("2D") {onUpdateDimension(.twoD)}
            Button("3D") {onUpdateDimension(.threeD)}
            Divider()
            // Remove the dimensionality. A default is selected in the executable
            Button("Default") {onUpdateDimension(nil)}
        } label: {
            Label("Set dimensionality...", systemImage: "square.and.pencil")
        }
        
        Divider()

        Button(role: .destructive) {
            onDelete()
        } label: {
            Label("Remove participant", systemImage: "trash")
        }
    }
}
