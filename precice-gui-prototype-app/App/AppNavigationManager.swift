//
//  AppNavigationManager.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 10.02.26.
//

import SwiftUI
import Combine

/// Different sub-apps
enum AppRoute {
    case dashboard
    case caseGenerate
    case configCheck
}

class AppNavigationManager: ObservableObject {
    @Published var currentRoute: AppRoute = .dashboard
        // Store the center point of the clicked card (0.0 to 1.0)
    @Published var zoomOrigin: UnitPoint = .center
    
        // Return to home
    func goHome() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentRoute = .dashboard
        }
    }
    
        // Navigate to a tool
    func navigate(to route: AppRoute, from origin: UnitPoint = .center) {
        
        self.zoomOrigin = origin
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentRoute = route
        }
    }
}
