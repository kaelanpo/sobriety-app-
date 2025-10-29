import SwiftUI

struct ActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(DS.ColorToken.card)
            )
            .foregroundStyle(DS.ColorToken.purpleGradient)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HStack(spacing: 12) {
        ActionButton(icon: "pencil", title: "Edit", action: {})
        ActionButton(icon: "square.and.arrow.up", title: "Share", action: {})
        ActionButton(icon: "book", title: "Journal", action: {})
    }
    .padding()
}

