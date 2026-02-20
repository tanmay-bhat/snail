import SwiftUI

struct PopoverView: View {
    @ObservedObject var networkMonitor: NetworkMonitor
    var onSettings: () -> Void
    var onQuit: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Today's Data Usage")
                .font(.headline)
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Uploaded")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(networkMonitor.formattedTotal(bytes: networkMonitor.todayUploadTotal))
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Downloaded")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(networkMonitor.formattedTotal(bytes: networkMonitor.todayDownloadTotal))
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                }
            }
            
            Divider()
            
            HStack {
                Button("Settings") {
                    onSettings()
                }
                
                Spacer()
                
                Button("Quit") {
                    onQuit()
                }
                .keyboardShortcut("q", modifiers: .command)
            }
        }
        .padding(16)
        .frame(width: 260)
    }
}
