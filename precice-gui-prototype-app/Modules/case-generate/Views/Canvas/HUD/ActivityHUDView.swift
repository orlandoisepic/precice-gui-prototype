    //
    //  ActivityHUDView.swift
    //  case-generate-app
    //
    //  Created by Orlando Ackermann on 05.02.26.
    //

import SwiftUI

struct ActivityHUDView: View {
        // State of the view model
    @Binding var state: GenerationState
    
        // Controls the "Show Details" sheet
    @State private var showLogSheet = false
    @State private var logContent: String = ""
    @State private var logTitle: String = ""
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
                // Dim background
            if state != .idle {
                Color.black.opacity(0.1)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
            
                // Panel to show when CLI exectuable is running
            if state != .idle {
                VStack(spacing: 16) {
                    
                    switch state {
                    case .idle:
                        EmptyView()
                    case .running:
                        VStack(spacing: 16) {
                            ProgressView().controlSize(.large).tint(.white)
                            Text("Generating files...").font(.headline)
                        }
                        .id("RunningState")
                        
                    case .success(let log):
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(.green)
                            
                            Text("Success!")
                                .font(.title3.bold())
                            
                            Text("Files generated successfully.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                Button("Show Details") {
                                    openLog(
                                        title: "Execution Log",
                                        content: log
                                    )
                                }
                                .buttonStyle(.bordered)
                                .cornerRadius(12)
                                Button("Done") {
                                    close()
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(themeManager.accentColor.color)
                                .cornerRadius(12)
                            }
                            .padding(.top, 4)
                        }
                        .id("SucessState")
                        
                    case .error(let title, let message, let details):
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(.red)
                            
                            Text(title)
                                .font(.title3.bold())
                                .foregroundStyle(.red)
                            
                            Text(message)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: 200)
                            
                            HStack {
                                
                                Button("Close") {
                                    close()
                                }
                                .buttonStyle(.bordered)
                                .cornerRadius(12)
                                
                                if let details = details, !details.isEmpty {
                                    Button("Show Details") {
                                        openLog(
                                            title: title + " - Details",
                                            content: details
                                        )
                                    }
                                    .cornerRadius(12)
                                    .buttonStyle(.borderedProminent)
                                    .tint(themeManager.accentColor.color)
                                }
                                
                            }
                            .padding(.top, 4)
                        }
                        .id("ErrorState")
                    }
                }
                .padding(30)
                .frame(width: 250)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(radius: 20)
                .transition(.scale.combined(with: .opacity))
            }
        }
            // The details
        .sheet(isPresented: $showLogSheet) {
            ConsoleLogView(
                title: logTitle,
                log: logContent,
                onClose: { showLogSheet = false
                })
            .frame(minWidth: 500, minHeight: 400)
            .background(.clear)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.7),
                value: state
            )
            .shadow(color: .black.opacity(0.3), radius: 20)
            .padding(10)
            
        }
            // This causes noticable lag upon clicking 'generate', but it would look nicer if it didn't :(
            // .animation(.spring(response: 0.3, dampingFraction: 0.7), value: state)
    }
        /// Close the "Show details" sheet
    private func close() {
        withAnimation { state = .idle }
    }
        /// Open the "show details" sheet
    private func openLog(title: String, content: String) {
        self.logTitle = title
        self.logContent = content
        self.showLogSheet = true
    }
}
