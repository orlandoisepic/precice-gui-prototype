
import SwiftUI

struct Participant: Identifiable, Codable {
    var id: UUID
    var name: String
    var solver: String
    var dimensionality: ParticipantDimensionality? = nil
    var position: CGPoint
    var patches: [Patch] = []
    
    init(id: UUID = UUID(), name: String, solver: String = "", dimensionality: ParticipantDimensionality? = nil, position: CGPoint) {
        self.id = id
        self.name = name
        self.solver = solver
        self.dimensionality = dimensionality
        self.position = position
        self.patches = []
    }
}

