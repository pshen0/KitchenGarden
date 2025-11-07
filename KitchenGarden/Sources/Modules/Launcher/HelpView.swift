import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
            HStack {
                Images.LocalImages.vegetables
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60)
                Text("Available Commands")
                    .font(.title)
                    .bold()
                Spacer()
                Button("Close") {
                    dismiss()
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(LauncherCommand.allCases, id: \.self) { command in
                    HStack(spacing: 20) {
                        Text(command.rawValue)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.accentColor)
                            .frame(width: 100, alignment: .leading)
                        
                        Text(command.description)
                            .foregroundColor(.primary)
                    }
                }
            }
    
            
            Text("Tip: Press Cmd+Shift+Space to open the launcher anywhere in the app")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
        .frame(width: 500, height: 300)
    }
}
