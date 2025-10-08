import SwiftUI

struct GamificationView: View {
    @EnvironmentObject var store: SobrietyStore
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DS.Spacing.lg) {
                    header
                    
                    achievementsSection
                    
                    progressSection
                    
                    insightsSection
                    
                    motivationalQuote
                }
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.bottom, DS.Spacing.xl)
            }
            .background(DS.ColorToken.creamBG.ignoresSafeArea(.all))
            .navigationTitle("Analysis")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("Your Progress")
                .font(DS.FontToken.rounded(28, .bold))
                .foregroundStyle(DS.ColorToken.textPrimary)
            
            Text("Track your recovery journey and celebrate wins")
                .font(DS.FontToken.rounded(16))
                .foregroundStyle(DS.ColorToken.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, DS.Spacing.lg)
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Achievements")
                .font(DS.FontToken.rounded(18, .semibold))
                .foregroundStyle(DS.ColorToken.textPrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: DS.Spacing.md) {
                ForEach(store.milestones) { milestone in
                    AchievementCard(milestone: milestone)
                }
            }
        }
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Recovery Stats")
                .font(DS.FontToken.rounded(18, .semibold))
                .foregroundStyle(DS.ColorToken.textPrimary)
            
            SoftCard {
                VStack(spacing: DS.Spacing.lg) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Current Streak")
                                .font(DS.FontToken.rounded(14))
                                .foregroundStyle(DS.ColorToken.textSecondary)
                            Text("\(store.currentStreak) days")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(DS.ColorToken.tint)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Longest Streak")
                                .font(DS.FontToken.rounded(14))
                                .foregroundStyle(DS.ColorToken.textSecondary)
                            Text("\(store.longestStreak) days")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(DS.ColorToken.mint)
                        }
                    }
                    
                    if let nextMilestone = store.currentMilestone {
                        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                            HStack {
                                Text("Next Milestone")
                                    .font(DS.FontToken.rounded(14))
                                    .foregroundStyle(DS.ColorToken.textSecondary)
                                Spacer()
                                Text("\(nextMilestone.days - store.currentStreak) days to go")
                                    .font(DS.FontToken.rounded(14))
                                    .foregroundStyle(DS.ColorToken.textSecondary)
                            }
                            
                            ProgressView(value: store.progressToNextMilestone)
                                .tint(DS.ColorToken.tint)
                                .scaleEffect(x: 1, y: 2, anchor: .center)
                        }
                    }
                }
            }
        }
    }
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Insights")
                .font(DS.FontToken.rounded(18, .semibold))
                .foregroundStyle(DS.ColorToken.textPrimary)
            
            LazyVStack(spacing: DS.Spacing.sm) {
                InsightCard(
                    title: "Mood Tracking",
                    description: "\(store.moodEntries.count) entries recorded",
                    icon: "heart.text.square",
                    color: DS.ColorToken.tint
                )
                
                InsightCard(
                    title: "Recovery Journey",
                    description: "\(store.currentStreak) days of progress",
                    icon: "chart.line.uptrend.xyaxis",
                    color: DS.ColorToken.mint
                )
                
                InsightCard(
                    title: "Milestones",
                    description: "\(store.milestones.count) achievements unlocked",
                    icon: "trophy.fill",
                    color: DS.ColorToken.peach
                )
            }
        }
    }
    
    private var motivationalQuote: some View {
        SoftCard {
            VStack(spacing: DS.Spacing.md) {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(DS.ColorToken.tint)
                
                Text(store.motivationalQuotes.randomElement() ?? "You've got this!")
                    .font(DS.FontToken.rounded(16, .medium))
                    .foregroundStyle(DS.ColorToken.textPrimary)
                    .multilineTextAlignment(.center)
                    .italic()
            }
        }
    }
}

struct AchievementCard: View {
    let milestone: Milestone
    
    var body: some View {
        SoftCard {
            VStack(spacing: DS.Spacing.sm) {
                Image(systemName: milestone.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(DS.ColorToken.tint)
                
                Text(milestone.title)
                    .font(DS.FontToken.rounded(14, .semibold))
                    .foregroundStyle(DS.ColorToken.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(milestone.description)
                    .font(DS.FontToken.rounded(12))
                    .foregroundStyle(DS.ColorToken.textSecondary)
                    .multilineTextAlignment(.center)
                
                if let achievedDate = milestone.achievedDate {
                    Text("Achieved \(achievedDate, style: .date)")
                        .font(DS.FontToken.rounded(10))
                        .foregroundStyle(DS.ColorToken.mint)
                }
            }
        }
    }
}

struct InsightCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        SoftCard {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DS.FontToken.rounded(16, .semibold))
                        .foregroundStyle(DS.ColorToken.textPrimary)
                    
                    Text(description)
                        .font(DS.FontToken.rounded(14))
                        .foregroundStyle(DS.ColorToken.textSecondary)
                }
                
                Spacer()
            }
        }
    }
}
