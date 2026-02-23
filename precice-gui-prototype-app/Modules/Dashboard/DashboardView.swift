//
//  DashboardView.swift
//  case-generate-app
//
//  Created by Orlando Ackermann on 10.02.26.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var navManager: AppNavigationManager
    @EnvironmentObject var themeManager: ThemeManager
     
    let columns = [
        // An adaptive number of columns of this size
        GridItem(.adaptive(minimum: 260), spacing: 20)
    ]
    
    var body: some View {
        VStack {
                // "Header" above scrollable window
            VStack(spacing: 16) {
                HStack(spacing: 20) {
                        // Logo
                    Image("preCICE-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 2, y: 5)
                        // Text next to logo
                    Text("preCICE")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundStyle(.primary)
                }
                    // Text below logo
                Text("The coupling library for partitioned multi-physics simulations")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 15)
            .padding(.bottom, 15)
            // The "apps"
            ScrollView {
                VStack(spacing: 30) {
                    LazyVGrid(columns: columns, spacing: 20) {
                            // Case generate
                        DashboardCard(
                            title: "case-generate",
                            description: "Design a topology and generate files.",
                        ) {
                            navManager.navigate(to: .caseGenerate)
                        } preview: {
                            GraphThumbnail()
                        }
                        .overlay(
                            GeometryReader { proxy in
                                Color.clear
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        let origin = getNormalizedCenter(proxy: proxy)
                                        navManager.navigate(to: .caseGenerate, from: origin)
                                    }
                            }
                        )
                            // TODO
                        DashboardCard(
                            title: "Exciting thing",
                            description: "Do something exciting.",
                            isDisabled: true
                        ) {
                        } preview: {
                            EmptyView()
                        }
                        
                        
                            // TODO
                        DashboardCard(
                            title: "Another one",
                            description: "Which will be awesome.",
                            isDisabled: true
                        ) {
                        } preview: {
                            EmptyView()
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
                .padding(.top, 20)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(themeManager.effectiveScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.2), lineWidth: 1)
            )
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .shadow(color: .black.opacity(themeManager.effectiveScheme == .dark ? 0.1 : 0.2), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            
        }
    }
    
        // Helper function to calculate normalized position of click on the screen
    func getNormalizedCenter(proxy: GeometryProxy) -> UnitPoint {
        let frame = proxy.frame(in: .global)
            // Get the window size (fallback to arbitrary size if window not found, though unlikely on macOS)
        let windowBounds = NSApp.keyWindow?.contentView?.bounds ?? CGRect(x: 0, y: 0, width: 1000, height: 800)
        
            // Calculate center relative to window (0.0 to 1.0)
            // Note: macOS coordinates (0,0) are usually bottom-left, but SwiftUI .global often maps to top-left relative.
            // We just need the ratio.
        let x = frame.midX / windowBounds.width
            // For macOS SwiftUI, sometimes Y needs flipping depending on context,
            // but usually .global in a ZStack works directly with UnitPoint.
        let y = 1.0 - (frame.midY / windowBounds.height)
        
        return UnitPoint(x: x, y: y)
    }
}
