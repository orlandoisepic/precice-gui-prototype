//
//  FileNode.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 06.02.26.
//

    //
    //  FileNode.swift
    //  case-generate-app
    //
    //  Created by Orlando Ackermann on 06.02.26.
    //

import Foundation

struct FileNode: Identifiable, Hashable {
    var id: String { path }
    let name: String
    let path: String // Relative path from project root (e.g. "results/data.txt")
    let isDirectory: Bool
    var children: [FileNode]? // Only folders have this
}
