import SwiftUI

struct RootView: View {
    @EnvironmentObject var navManager: AppNavigationManager
    @EnvironmentObject var graphCanvasViewModel: GraphCanvasViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            switch navManager.currentRoute {
            case .dashboard:
                DashboardView()
                    .transition(
                        .asymmetric(
                            // Coming back: Scale from huge (5x) down to 1x
                            insertion: .opacity.combined(with: .scale(scale: 5, anchor: navManager.zoomOrigin)),
                            // Going away: Scale from 1x up to huge (5x)
                            removal: .opacity.combined(with: .scale(scale: 5, anchor: navManager.zoomOrigin))
                        )
                    )
                
            case .caseGenerate:
                CanvasView()
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.3, anchor: navManager.zoomOrigin)),
                            removal: .opacity.combined(with: .scale(scale: 0.1, anchor: .center))
                        )
                    )
                    .environmentObject(graphCanvasViewModel)
            
            case .configCheck:
                EmptyView()
            
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: navManager.currentRoute)
            // Place the home button over everything else
        .overlay(alignment: .topLeading) {
                // Only show if not on the dashboard
            if navManager.currentRoute != .dashboard {
                HomeButton()
                    .padding(.leading, 24)
                    .padding(.top, 24)
                    .transition(.opacity)
            }
        }
        .background {
            Color(nsColor: .windowBackgroundColor)
                .ignoresSafeArea()
        }
        .preferredColorScheme(themeManager.selectedScheme)
        
    }
}
