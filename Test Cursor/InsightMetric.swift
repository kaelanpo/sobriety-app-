import SwiftUI

struct InsightMetric: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "#8E8E93"))
                .textCase(.uppercase)
                .tracking(0.5)
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#1C1C1E"))
            
            Text(subtitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "#6B6B6B"))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.7))
        )
    }
}

#Preview {
    InsightMetric(title: "Most Frequent", value: "😊", subtitle: "Happy")
        .padding()
        .background(Color(hex: "#F8F9FA"))
}

