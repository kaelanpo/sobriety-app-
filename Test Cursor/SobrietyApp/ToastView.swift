import SwiftUI

struct ToastView: View {
    let message: String
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            if isPresented {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white)
                    
                    Text(message)
                        .font(DS.FontToken.rounded(15, .semibold))
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.vertical, DS.Spacing.md)
                .background(
                    Capsule()
                        .fill(DS.ColorToken.purple300)
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.bottom, 100)
                .transition(.move(edge: .bottom))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPresented)
            }
        }
    }
}

// View modifier for easy toast usage
extension View {
    func toast(message: String, isPresented: Binding<Bool>) -> some View {
        ZStack {
            self
            ToastView(message: message, isPresented: isPresented)
        }
    }
}

