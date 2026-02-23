import SwiftUI
    // Defines the strength of the connection
enum EdgeStrength: String, CaseIterable, Codable {
    case weak
    case strong
}

enum DataType: String, CaseIterable, Codable {
    case scalar
    case vector
}
