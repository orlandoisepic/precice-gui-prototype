//
//  GenerationState 2.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 08.02.26.
//


enum GenerationState: Equatable {
    case idle
    case running
    // Success now carries the full console log
    case success(log: String)
    // Error now carries a Title, a User-Friendly Message, and optional Technical Details
    case error(title: String, message: String, details: String?)
}