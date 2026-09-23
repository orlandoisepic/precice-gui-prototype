import SwiftUI

struct LocationNode: Identifiable, Codable {
    let id: UUID
    var names: [String]
    var angle: Double
    let parentId: UUID
    var type: LocationType
    
    init(id: UUID = UUID(), names: [String], angle: Double, parentId: UUID, type: LocationType = .surface) {
        self.id = id
        self.names = names
        self.angle = angle
        self.parentId = parentId
        self.type = type
    }
}
