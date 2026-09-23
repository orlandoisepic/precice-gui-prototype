//
//  LocationLayer.swift
//  precice-gui-prototype
//
//  Created by Orlando Ackermann on 21.09.26.
//
import SwiftUI

struct LocationLayer: View {
    @ObservedObject var viewModel: GraphCanvasViewModel

    var body: some View {
        ZStack {
            ForEach($viewModel.participants) { $participant in
                LocationNodeRing(
                    locationNodes: $participant.locationNodes,
                    parentID: participant.id,
                    viewModel: viewModel
                )
                // Ensure the location node follows the participant node
                .position(participant.position)
            }
        }
    }
}
