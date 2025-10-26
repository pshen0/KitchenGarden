import SwiftUI

struct LauncherView: View {
    @State private var commandText = ""
    
    var body: some View {
        HStack {
            Images.LocalImages.tomato
                .resizable()
                .scaledToFill()
                .frame(height: 30)
                .padding()
            
            TextField("Enter command...", text: $commandText)
                .frame(width: 400, height: 50)
                .cornerRadius(20)
                .textFieldStyle(.plain)
                .font(.system(size: 20))
                .padding()
            
            Spacer()
            
        }
        .background(Color(NSColor.controlBackgroundColor))
        .frame(width: 500, height: 50)
        .cornerRadius(20)
    }
}
