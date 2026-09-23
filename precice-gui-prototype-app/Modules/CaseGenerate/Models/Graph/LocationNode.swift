import SwiftUI

struct LocationNode: Identifiable, Codable {
    let id: UUID
    var name: String
    var angle: Double
    let parentId: UUID
    var type: LocationType
    
    init(id: UUID = UUID(), name: String, angle: Double, parentId: UUID, type: LocationType = .surface) {
        self.id = id
        self.name = name
        self.angle = angle
        self.parentId = parentId
        self.type = type
    }
}
