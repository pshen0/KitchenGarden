import SwiftUI

struct TasksHeaderView: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack {
                    Text("Board")
                        .font(.title)
                        .bold()
                    Images.LocalImages.corn
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 42, height: 42)
                }
                .foregroundColor(.primary)
                
                Spacer()
            }
            .padding()
            .background(Colors.yellowBackground)
            
            Rectangle()
                .fill(Colors.yellowSecondary)
                .frame(height: 1)
                .padding(.horizontal, 16)
            
            HStack {
                Button(action: {}) {
                    HStack {
                        Text("Priority")
                        Images.SystemImages.chevronDown
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Colors.yellowSecondary, lineWidth: 1)
                )
                .padding(.leading, 16)
                .padding(.top, 12)
                
                Spacer()
            }
        }
    }
}
