    //
    //  ProjectRow.swift
    //  case-generate-app
    //
    //  Created by Orlando Ackermann on 05.02.26.
    //

import SwiftUI
    
struct ProjectRow: View {
    let name: String
    let isActive: Bool
    let hasUnsavedChanges: Bool
    
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 8) {
                
            // ">" for expanding / folding the folder
            Button(action: {
                withAnimation(.snappy) { onToggleExpand() }
            }) {
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .frame(width: 20, height: 20)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
                // Folder Icon
            Image(systemName: "folder.fill")
                .foregroundStyle(themeManager.accentColor.color)
            
                // Name
            HStack(spacing: 0) {
                Text(name)
                    .fontWeight(isActive ? .semibold : .regular)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .font(.body)
                
                if hasUnsavedChanges {
                    Text("*")
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
                // Checkmark if active
            if isActive {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .padding(.trailing, 8)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 6)
        .cornerRadius(6)
        .contentShape(Rectangle())
    }
}
