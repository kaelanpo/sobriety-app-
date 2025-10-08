import SwiftUI

// Colors tuned for a Hinge-like, warm, soft UI.
public enum DS {
    public enum ColorToken {
        public static let creamBG = Color(hex: "#FFF6E9")
        public static let card = Color.white
        public static let textPrimary = Color(hex: "#1E1E1E")
        public static let textSecondary = Color(hex: "#6B6B6B")
        public static let tint = Color(hex: "#FF6EA9")      // warm pink
        public static let mint = Color(hex: "#8EE3D0")
        public static let peach = Color(hex: "#FFC6A8")
        public static let shadow = Color.black.opacity(0.08)
        public static let divider = Color.black.opacity(0.06)
        
        // Orange sherbet gradient colors
        public static let orangeSherbet = Color(hex: "#FF8C42")  // orange sherbet
        public static let gradientWhite = Color.white
    }

    public enum Radius {
        public static let xl: CGFloat = 24
        public static let lg: CGFloat = 18
        public static let md: CGFloat = 12
        public static let sm: CGFloat = 8
    }

    public enum Spacing {
        public static let xl: CGFloat = 28
        public static let lg: CGFloat = 20
        public static let md: CGFloat = 14
        public static let sm: CGFloat = 10
        public static let xs: CGFloat = 6
    }

    public enum FontToken {
        public static func rounded(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
            .system(size: size, weight: weight, design: .rounded)
        }
    }
}

// MARK: - Helpers
extension Color {
    init(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: s).scanHexInt64(&rgb)
        let r = Double((rgb & 0xFF0000) >> 16) / 255
        let g = Double((rgb & 0x00FF00) >> 8) / 255
        let b = Double(rgb & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

struct SoftCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .padding(DS.Spacing.lg)
            .background(DS.ColorToken.card)
            .cornerRadius(DS.Radius.xl)
            .shadow(color: DS.ColorToken.shadow, radius: 18, x: 0, y: 10)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DS.FontToken.rounded(17, .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(DS.ColorToken.tint)
            .cornerRadius(DS.Radius.lg)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.9), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DS.FontToken.rounded(17, .semibold))
            .foregroundColor(DS.ColorToken.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(DS.ColorToken.card)
            .cornerRadius(DS.Radius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.lg)
                    .stroke(DS.ColorToken.textSecondary.opacity(0.3), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.9 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.9), value: configuration.isPressed)
    }
}

struct AppGradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                DS.ColorToken.gradientWhite,
                DS.ColorToken.orangeSherbet
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea(.all)
    }
}
