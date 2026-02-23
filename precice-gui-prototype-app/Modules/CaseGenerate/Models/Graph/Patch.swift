import SwiftUI

struct Patch: Identifiable, Codable {
    let id: UUID
    var name: String
    var angle: Double
    let parentId: UUID
    
    init(id:UUID = UUID(), name: String, angle: Double, parentId:UUID) {
        self.id = id
        self.name = name
        self.angle = angle
        self.parentId = parentId
    }
}
