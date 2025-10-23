import SwiftUI

struct SobrietyDashboard: View {
    @EnvironmentObject var store: SobrietyStore
    @State private var showingRelapseConfirmation = false
    @State private var shimmerOffset: CGFloat = -200
    @Binding var selectedTab: Int
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: DS.Spacing.lg) {
                    header
                    
                    daysCleanCard
                    
                    nextMilestoneCard
                    
                    needHelpButton
                    
                    yourStatsSection
                }
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.bottom, DS.Spacing.xl)
            }
            .background(DS.ColorToken.creamBG.ignoresSafeArea(.all))
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .confirmationDialog(
                "Mark Relapse",
                isPresented: $showingRelapseConfirmation,
                titleVisibility: .visible
            ) {
                Button("Yes, I relapsed", role: .destructive) {
                    store.markRelapse()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will reset your current streak to 0. Remember, recovery is a journey and setbacks are part of the process.")
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        selectedTab = 1 // Navigate to goals tab
                    }) {
                        Image(systemName: "target")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(DS.ColorToken.tint)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .padding(.trailing, DS.Spacing.lg)
                    .padding(.bottom, DS.Spacing.xl)
                }
            }
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("Sober")
                .font(DS.FontToken.rounded(32, .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.black, .gray.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    // Shimmer effect
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.6), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .rotationEffect(.degrees(30))
                        .offset(x: shimmerOffset)
                        .mask(
                            Text("Sober")
                                .font(DS.FontToken.rounded(32, .bold))
                        )
                )
                .onAppear {
                    withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                        shimmerOffset = 200
                    }
                }
            
            Text("You've got this. One day at a time.")
                .font(DS.FontToken.rounded(16))
                .foregroundStyle(DS.ColorToken.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, DS.Spacing.lg)
    }
    
    private var daysCleanCard: some View {
        SoftCard {
            VStack(spacing: DS.Spacing.md) {
                Text("Days Clean")
                    .font(DS.FontToken.rounded(18, .semibold))
                    .foregroundStyle(DS.ColorToken.textSecondary)
                
                Text("\(store.currentStreak)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(DS.ColorToken.tint)
                
                if store.currentStreak == 0 {
                    Text("Start your journey today")
                        .font(DS.FontToken.rounded(16))
                        .foregroundStyle(DS.ColorToken.textSecondary)
                } else {
                    Text(store.currentStreak == 1 ? "Day Clean" : "Days Clean")
                        .font(DS.FontToken.rounded(16))
                        .foregroundStyle(DS.ColorToken.textSecondary)
                }
            }
        }
    }
    
    private var nextMilestoneCard: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(DS.ColorToken.tint)
                        .font(.system(size: 16))
                    Text("Next Milestone")
                        .font(DS.FontToken.rounded(18, .semibold))
                        .foregroundStyle(DS.ColorToken.textPrimary)
                }
                
                if let milestone = store.currentMilestone {
                    VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                        Text("\(milestone.days - store.currentStreak) days to go")
                            .font(DS.FontToken.rounded(14))
                            .foregroundStyle(DS.ColorToken.textSecondary)
                        
                        Text("\(milestone.days) days → \(milestone.title)")
                            .font(DS.FontToken.rounded(16, .semibold))
                            .foregroundStyle(DS.ColorToken.tint)
                        
                        Text(milestone.description)
                            .font(DS.FontToken.rounded(14))
                            .foregroundStyle(DS.ColorToken.textSecondary)
                    }
                } else {
                    Text("All milestones achieved! 🎉")
                        .font(DS.FontToken.rounded(16, .semibold))
                        .foregroundStyle(DS.ColorToken.mint)
                }
            }
        }
    }
    
    private var needHelpButton: some View {
        Button(action: {
            // Handle need help action
        }) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.white)
                Text("Need Help?")
                    .font(DS.FontToken.rounded(17, .semibold))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.vertical, DS.Spacing.md)
            .background(DS.ColorToken.tint)
            .cornerRadius(DS.Radius.lg)
        }
    }
    
    private var yourStatsSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Your Stats")
                .font(DS.FontToken.rounded(18, .semibold))
                .foregroundStyle(DS.ColorToken.textPrimary)
            
            HStack(spacing: DS.Spacing.lg) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(store.currentStreak)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(DS.ColorToken.tint)
                    Text("Current Streak")
                        .font(DS.FontToken.rounded(12))
                        .foregroundStyle(DS.ColorToken.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(store.longestStreak)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(DS.ColorToken.mint)
                    Text("Longest Streak")
                        .font(DS.FontToken.rounded(12))
                        .foregroundStyle(DS.ColorToken.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
