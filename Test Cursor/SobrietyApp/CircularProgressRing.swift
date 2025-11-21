import SwiftUI

struct CircularProgressRing: View {
    let progress: Double // 0.0 to 1.0
    let size: CGFloat
    let strokeWidth: CGFloat
    let completedColor: Color
    let backgroundColor: Color
    let completedCount: Int
    let totalCount: Int
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(backgroundColor, lineWidth: strokeWidth)
                .frame(width: size, height: size)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    completedColor,
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: animatedProgress)
            
            // Center content
            VStack(spacing: 2) {
                Text("\(completedCount)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(DS.ColorToken.purple300)
                
                Text("Completed")
                    .font(DS.FontToken.rounded(11))
                    .foregroundStyle(DS.ColorToken.textSecondary)
                
                Spacer()
                    .frame(height: 8)
                
                Text("\(totalCount)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(DS.ColorToken.mint)
                
                Text("Total Orbits")
                    .font(DS.FontToken.rounded(11))
                    .foregroundStyle(DS.ColorToken.textSecondary)
            }
        }
        .onAppear {
            withAnimation {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation {
                animatedProgress = newValue
            }
        }
    }
}

#Preview {
    CircularProgressRing(
        progress: 0.6,
        size: 200,
        strokeWidth: 12,
        completedColor: DS.ColorToken.mint,
        backgroundColor: DS.ColorToken.textSecondary.opacity(0.2),
        completedCount: 3,
        totalCount: 5
    )
    .padding()
}

