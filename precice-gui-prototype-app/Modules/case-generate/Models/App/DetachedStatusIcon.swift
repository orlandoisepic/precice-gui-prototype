import SwiftUI

struct DetachedStatusIcon: View {
    @State private var showInfo = false
    
    var body: some View {
        Button(action: { showInfo.toggle() }) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14))
                .foregroundStyle(.orange)
                .symbolEffect(.pulse)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showInfo, arrowEdge: .bottom) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "link.badge.plus")
                        .foregroundStyle(.secondary)
                    Text("File Detached")
                        .font(.headline)
                }
                
                Text("This file is being edited manually and is no longer in-sync with the Graph.")
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
                
                Divider()
                
                    // INSTRUCTION ONLY
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                    Text("To restore the connection (and overwrite manual edits), click 'Generate' in the Graph Canvas.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .frame(width: 260)
        }
    }
}
