import SwiftUI

struct InsightMetric: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DS.ColorToken.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(DS.ColorToken.textPrimary)
            
            Text(subtitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(DS.ColorToken.textSecondary)
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
        .background(DS.ColorToken.creamBG)
}

