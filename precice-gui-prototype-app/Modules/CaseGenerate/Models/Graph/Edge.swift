import SwiftUI



struct Edge: Identifiable, Codable {
    // Unique ID for the connection itself
    let id: UUID
    
    // The direction is implied: FROM source TO target
    var sourceLocationNodeId: UUID
    var targetLocationNodeId: UUID
    
    // Attributes
    var data: String            // "The data that is exchanged"
    var dataType: DataType?     // scalar or vector
    var strength: EdgeStrength  // "Weak" or "Strong"
    
    init(id: UUID = UUID(),
         sourceLocationNodeId: UUID,
         targetLocationNodeId: UUID,
         data: String = "Data",
         dataType: DataType? = nil,
         strength: EdgeStrength = .weak) {
        
        self.id = id
        self.sourceLocationNodeId = sourceLocationNodeId
        self.targetLocationNodeId = targetLocationNodeId
        self.data = data
        self.dataType = dataType
        self.strength = strength
    }
}
