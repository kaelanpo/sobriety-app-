import SwiftUI

struct FilterChip: View {
    let title: String
    var emoji: String? = nil
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let emoji = emoji {
                    Text(emoji)
                        .font(.system(size: 16))
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? DS.ColorToken.purpleLight.opacity(0.15) : Color(hex: "#F2F2F7"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? AnyShapeStyle(DS.ColorToken.purpleGradient) : AnyShapeStyle(Color.clear), lineWidth: 2)
            )
            .foregroundStyle(isSelected ? AnyShapeStyle(DS.ColorToken.purpleGradient) : AnyShapeStyle(Color(hex: "#1C1C1E")))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HStack {
        FilterChip(title: "All", isSelected: true, action: {})
        FilterChip(title: "Happy", emoji: "😊", isSelected: false, action: {})
        FilterChip(title: "Calm", emoji: "😌", isSelected: false, action: {})
    }
    .padding()
}

