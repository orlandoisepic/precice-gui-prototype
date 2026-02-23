    //
    //  SidebarHeaderView.swift
    //  case-generate-app
    //
    //  Created by Orlando Ackermann on 05.02.26.
    //

import SwiftUI

struct SidebarHeaderView: View {
    @ObservedObject var viewModel: GraphCanvasViewModel
    @Binding var isVisible: Bool
    
    @EnvironmentObject var themeManager: ThemeManager
        // Actions to trigger alerts in the parent
    var onCreateProject: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            
            CloseSidebarButton(isVisible: $isVisible)
            
            Text("Projects")
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(1)
            
            Spacer()
            
            AddProjectButton(onCreateProject: onCreateProject)
        }
        .padding()
        .background(.ultraThinMaterial)
            // Subtle separator line at the bottom
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.black.opacity(0.05)),
            alignment: .bottom
        )
    }
}
