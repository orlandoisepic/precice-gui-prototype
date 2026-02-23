//
//  SidebarItem.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 05.02.26.
//

import SwiftUI

enum SidebarItem: Hashable {
    case project(String)
    case file(project: String, path: String)
}
