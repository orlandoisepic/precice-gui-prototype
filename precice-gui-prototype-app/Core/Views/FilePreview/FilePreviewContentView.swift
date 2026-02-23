    //
    //  FilePreviewContentView.swift
    //  case-generate-app
    //
    //  Created by Orlando Ackermann on 07.02.26.
    //

import SwiftUI
    // TODO This needs to be updated to receive the correct buttons depending on which app we are in
struct FilePreviewContentView: View {
    let data: PreviewData
    @EnvironmentObject var graphCanvasViewModel: GraphCanvasViewModel
    @StateObject private var filePreviewViewModel = FilePreviewViewModel()
    
    @State private var warningShown = false
    @State private var showWarning = false
    @State private var isEditable = false
    
        // String for line numbers
    private var lineNumbers: String {
        if filePreviewViewModel.content.isEmpty { return "" }
        
        var lines = filePreviewViewModel.content.components(
            separatedBy: .newlines
        )
        
        if lines.last?.isEmpty == true {
            lines.removeLast()
        }
        
        let count = lines.count
        let numbers = (1...count+1).map{ "\($0)" }.joined(separator: "\n")
        if numbers == "" {
            return "1"
        } else {
            return numbers
        }
    }
    
    private var dataURL: URL {
        return ProjectManager.getFileURL(forProject: data.project, with: data.path)
    }
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                    // Header
                ZStack {
                        // Use own HStack to center filename
                    HStack(spacing: 0) {
                        DetachedStatusIcon()
                            .padding(.trailing, 2)
                            .transition(.scale.combined(with: .opacity))
                            .opacity(graphCanvasViewModel.isDetached(path: dataURL) ? 1 : 0)
                        Text(data.filename)
                            .font(.body.weight(.medium))
                            .foregroundStyle(.primary.opacity(0.8))
                        Text("*")
                            .font(.body.weight(.medium))
                            .foregroundStyle(.primary.opacity(0.8))
                            .opacity(filePreviewViewModel.isDirty ? 1 : 0)
                            .help("Unsaved changes")
                            .padding(.trailing, 6)
                    }
                    // TODO Buttons depend on currently opened app
                    HStack (spacing: 8) {
                            // Push to the left
                        Spacer()
                            // Show run edit save buttons only for yaml files
                        if data.filename.hasSuffix("yaml") || data.filename.hasSuffix("yml") {
                            // Data is the currently selected file. When clicking the run button, the currently selected file is used for execution
                            let topologyPath = ProjectManager.getURL(forProject: data.project).appendingPathComponent(data.path)
                            RunButton(
                                filePreviewViewModel: filePreviewViewModel,
                                graphCanvasViewModel: graphCanvasViewModel,
                                topologyPath: topologyPath
                            )
                            
                            EditButton(isEditable: Binding(
                                get: { isEditable },
                                set: { response in
                                        // isEditable has been set to true => The button was clicked to edit
                                        // We want to check if the user has seen a warning already
                                    if response {
                                            // Warning has already been shown, so just make it editable
                                        if warningShown {
                                            isEditable = true
                                        } else {
                                            showWarning = true
                                        }
                                            // It has been set to false => button was clicked to disable edits
                                    } else {
                                        isEditable = false
                                    }
                                }
                            ))
                            SaveButton(
                                action: filePreviewViewModel.saveFile,
                                isDirty: $filePreviewViewModel.isDirty
                            )
                        }
                        
                        CopyButton { filePreviewViewModel.content }
                        
                        OpenExternalButton(
                            fileURL: ProjectManager
                                .getURL(forProject: data.project)
                                .appendingPathComponent(data.path),
                            textContent: filePreviewViewModel.content
                        )
                    }
                    
                }
                .frame(height: 34)
                .padding(4)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial.opacity(0.9))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color.black.opacity(0.05)),
                    alignment: .bottom
                )
                
                    // Content of the file
                GeometryReader { geo in
                    ScrollView([.vertical, .horizontal]) {
                        HStack(alignment: .top, spacing: 12) {
                                // First column is line numbers
                            Text(lineNumbers)
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.trailing)
                                .frame(minWidth: 20, alignment: .trailing)
                                .padding(.leading, 8)
                                .textSelection(.disabled)
                                .lineSpacing(4)
                            
                            NativeTextView(
                                text: $filePreviewViewModel.content,
                                fontSize: 14,
                                lineSpacing: 4,
                                minWidth: geo.size.width,
                                minHeight: geo.size.height,
                                onTextChange: {
                                    if !filePreviewViewModel.isDirty {
                                        filePreviewViewModel.isDirty = true
                                    }
                                },
                                isEditable: $isEditable
                            )
                            .frame(
                                minWidth: geo.size.width,
                                alignment: .leading
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .frame(
                            minHeight: geo.size.height,
                            alignment: .topLeading
                        )
                    }
                }
            }
            .containerBackground(.ultraThinMaterial, for: .window)
            .onAppear {
                filePreviewViewModel.loadFile(data: data)
                if graphCanvasViewModel.isDetached(path: dataURL) {
                        // If the graph and topology are already out of sync, there is no need to show the warning again.
                    warningShown = true
                }
            }
            .background(Color.white.opacity(0.01))
                // Without this, the header would have two rows
            .ignoresSafeArea(edges: [.top])
            .sheet(isPresented: $showWarning) {
                WarningMessage(
                    isEditable: $isEditable,
                    warningShown: $warningShown,
                    data: data
                )
                .shadow(color: .black.opacity(0.3), radius: 20)
            }
        }
    }
}
    

