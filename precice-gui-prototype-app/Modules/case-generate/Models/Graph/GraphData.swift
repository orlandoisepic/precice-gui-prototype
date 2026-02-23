//
//  GraphData.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 05.02.26.
//


// Keep the Struct
struct GraphData: Codable {
    let participants: [Participant]
    let edges: [Edge]
}