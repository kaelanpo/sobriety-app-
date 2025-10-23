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
                    .fill(isSelected ? Color(hex: "#FF6EA9").opacity(0.15) : Color(hex: "#F2F2F7"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color(hex: "#FF6EA9") : Color.clear, lineWidth: 2)
            )
            .foregroundColor(isSelected ? Color(hex: "#FF6EA9") : Color(hex: "#1C1C1E"))
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

