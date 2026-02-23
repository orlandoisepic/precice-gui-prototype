//
//  PreviewData.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 07.02.26.
//


import Foundation

struct PreviewData: Codable, Hashable {
    let filename: String
    let project: String
    let path: String
}
