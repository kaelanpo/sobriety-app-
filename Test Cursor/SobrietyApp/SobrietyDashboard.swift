import SwiftUI

#if canImport(ActivityKit)
import ActivityKit
#endif

#if canImport(WidgetKit)
import WidgetKit
#endif

// MARK: - iOS 18 Live Activities Support
#if canImport(ActivityKit) && canImport(WidgetKit)
@available(iOS 18.0, *)
struct SobrietyActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var currentStreak: Int
        var daysToNextMilestone: Int
        var milestoneTitle: String
    }
    
    var startDate: Date
}

@available(iOS 18.0, *)
struct SobrietyLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SobrietyActivityAttributes.self) { context in
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("\(context.state.currentStreak) Day\(context.state.currentStreak == 1 ? "" : "s") Strong")
                        .font(.headline)
                    Spacer()
                }
                Text("\(context.state.daysToNextMilestone) days to \(context.state.milestoneTitle)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .activityBackgroundTint(Color(.systemBackground))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        VStack(alignment: .leading) {
                            Text("\(context.state.currentStreak) Days")
                                .font(.headline)
                            Text("Streak Active")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing) {
                        Text("Next: \(context.state.milestoneTitle)")
                            .font(.subheadline)
                        Text("\(context.state.daysToNextMilestone) days")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } compactLeading: {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
            } compactTrailing: {
                Text("\(context.state.currentStreak)")
                    .font(.caption.bold())
            } minimal: {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
            }
        }
    }
}

// Note: Widget bundle would be declared in a separate file for a Widget Extension
// This widget can be added to an existing Widget Extension target if needed
#endif

// MARK: - Compact Streak Visualization
struct CompactStreakView: View {
    @EnvironmentObject var store: SobrietyStore
    @State private var isExpanded = false
    @State private var currentCalendarDate = Date()
    
    private let calendar = Calendar.current
    private let maxVisibleChainLinks = 7
    
    var body: some View {
        VStack(spacing: 0) {
            // Compact view - horizontal chain/arc
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: DS.Spacing.md) {
                    // Chain/Arc visualization
                    HStack(spacing: 4) {
                        ForEach(0..<min(store.currentStreak, maxVisibleChainLinks), id: \.self) { index in
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [DS.ColorToken.purpleLight, DS.ColorToken.purpleDark],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }
                        if store.currentStreak > maxVisibleChainLinks {
                            Text("+\(store.currentStreak - maxVisibleChainLinks)")
                                .font(DS.FontToken.rounded(12, .semibold))
                                .foregroundStyle(DS.ColorToken.purpleDark)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(store.currentStreak) Day\(store.currentStreak == 1 ? "" : "s") Strong")
                            .font(DS.FontToken.rounded(17, .bold))
                            .foregroundStyle(DS.ColorToken.textPrimary)
                        Text("Tap to view calendar")
                            .font(DS.FontToken.rounded(11))
                            .foregroundStyle(DS.ColorToken.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(DS.ColorToken.purpleLight)
                }
                .padding(DS.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DS.Radius.lg)
                        .fill(Color(.systemBackground))
                        .shadow(color: DS.ColorToken.shadow, radius: 6, x: 0, y: 3)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Streak: \(store.currentStreak) days. Tap to expand calendar")
            
            // Expanded mini-calendar
            if isExpanded {
                MiniCalendarView(
                    currentDate: $currentCalendarDate,
                    isExpanded: $isExpanded
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
                .zIndex(1)
            }
        }
    }
}

// MARK: - Mini Calendar View
struct MiniCalendarView: View {
    @EnvironmentObject var store: SobrietyStore
    @Binding var currentDate: Date
    @Binding var isExpanded: Bool
    @State private var showingCloseButton = true
    
    private let calendar = Calendar.current
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }
    
    private var calendarDays: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.end - 1) else {
            return []
        }
        
        var days: [Date] = []
        var currentDate = monthFirstWeek.start
        
        while currentDate < monthLastWeek.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
    
    private var checkedInDaysThisMonth: Int {
        let monthStart = calendar.dateInterval(of: .month, for: currentDate)?.start ?? currentDate
        let monthEnd = calendar.dateInterval(of: .month, for: currentDate)?.end ?? currentDate
        
        return store.checkInDates.filter { date in
            date >= monthStart && date < monthEnd
        }.count
    }
    
    var body: some View {
        VStack(spacing: DS.Spacing.sm) {
            // Month header with close button
            HStack {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isExpanded = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(DS.ColorToken.textSecondary.opacity(0.6))
                }
                
                Spacer()
                
                Text(dateFormatter.string(from: currentDate))
                    .font(DS.FontToken.rounded(16, .bold))
                    .foregroundStyle(DS.ColorToken.textPrimary)
                
                Spacer()
                
                // Navigation buttons
                HStack(spacing: DS.Spacing.md) {
                    Button(action: {
                        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(DS.ColorToken.purpleLight)
                    }
                    
                    Button(action: {
                        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(DS.ColorToken.purpleLight)
                    }
                }
            }
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.top, DS.Spacing.sm)
            
            // Day headers
            HStack(spacing: 0) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(DS.FontToken.rounded(11, .semibold))
                        .foregroundStyle(DS.ColorToken.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, DS.Spacing.lg)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 6) {
                ForEach(calendarDays, id: \.self) { date in
                    MiniCalendarDayView(
                        date: date,
                        isCurrentMonth: calendar.isDate(date, equalTo: currentDate, toGranularity: .month),
                        isToday: calendar.isDateInToday(date),
                        isCheckedIn: store.hasCheckedInOnDate(date)
                    )
                }
            }
            .padding(.horizontal, DS.Spacing.lg)
            
            // Summary
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(DS.ColorToken.mint)
                    .font(.system(size: 13))
                Text("\(checkedInDaysThisMonth) day\(checkedInDaysThisMonth == 1 ? "" : "s") checked in this month")
                    .font(DS.FontToken.rounded(12, .medium))
                    .foregroundStyle(DS.ColorToken.textSecondary)
                Spacer()
            }
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.bottom, DS.Spacing.sm)
        }
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.lg)
                .fill(Color(.systemBackground))
                .shadow(color: DS.ColorToken.shadow, radius: 6, x: 0, y: 3)
        )
        .padding(.top, DS.Spacing.xs)
    }
}

struct MiniCalendarDayView: View {
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    let isCheckedIn: Bool
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .font(DS.FontToken.rounded(12, .medium))
                .foregroundStyle(textColor)
            
            if isCheckedIn {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(DS.ColorToken.mint)
            }
        }
        .frame(width: 28, height: 28)
        .background(backgroundColor)
        .cornerRadius(DS.Radius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.sm)
                .stroke(borderColor, lineWidth: isToday ? 1.5 : 0)
        )
    }
    
    private var textColor: Color {
        if isCheckedIn {
            return DS.ColorToken.purpleDark
        } else if isToday {
            return DS.ColorToken.purpleLight
        } else if isCurrentMonth {
            return DS.ColorToken.textPrimary
        } else {
            return DS.ColorToken.textSecondary.opacity(0.5)
        }
    }
    
    private var backgroundColor: Color {
        if isCheckedIn {
            return DS.ColorToken.mint.opacity(0.2)
        } else if isToday {
            return DS.ColorToken.purpleLight.opacity(0.15)
        } else {
            return Color.clear
        }
    }
    
    private var borderColor: Color {
        if isToday {
            return DS.ColorToken.purpleLight
        } else {
            return Color.clear
        }
    }
}

// MARK: - Merged Check-In and Milestone Card
struct CheckInMilestoneCard: View {
    @EnvironmentObject var store: SobrietyStore
    @State private var isPressed = false
    
    private var hasCheckedInToday: Bool {
        guard let lastCheckIn = store.lastCheckInDate else { return false }
        return Calendar.current.isDate(lastCheckIn, inSameDayAs: Date())
    }
    
    private var daysToNextMilestone: Int {
        guard let milestone = store.currentMilestone else { return 0 }
        return milestone.days - store.currentStreak
    }
    
    private var milestoneTitle: String {
        store.currentMilestone?.title ?? "Milestone"
    }
    
    private var milestoneDescription: String {
        store.currentMilestone?.description ?? "Keep going!"
    }
    
    var body: some View {
        Button(action: {
            if !hasCheckedInToday {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                store.checkIn()
                
                // Update Live Activity if available
                #if canImport(ActivityKit)
                if #available(iOS 18.0, *) {
                    updateLiveActivity()
                }
                #endif
            }
        }) {
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                HStack {
                    Image(systemName: hasCheckedInToday ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(hasCheckedInToday ? DS.ColorToken.mint : DS.ColorToken.purpleLight)
                    
                    Text(hasCheckedInToday ? "Checked In Today" : "Check In Today")
                        .font(DS.FontToken.rounded(17, .bold))
                        .foregroundStyle(DS.ColorToken.textPrimary)
                    
                    if !hasCheckedInToday {
                        Spacer()
                        if daysToNextMilestone > 0 {
                            Text("• \(daysToNextMilestone) Days to \(milestoneTitle)")
                                .font(DS.FontToken.rounded(14, .medium))
                                .foregroundStyle(DS.ColorToken.purpleDark)
                        }
                    }
                }
                
                if daysToNextMilestone > 0 {
                    Text(milestoneDescription)
                        .font(DS.FontToken.rounded(14))
                        .foregroundStyle(DS.ColorToken.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DS.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.lg)
                    .fill(
                        hasCheckedInToday ?
                            LinearGradient(
                                colors: [DS.ColorToken.mint.opacity(0.15), DS.ColorToken.mint.opacity(0.25)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [DS.ColorToken.purpleLight.opacity(0.1), DS.ColorToken.purpleDark.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.lg)
                            .stroke(
                                hasCheckedInToday ? DS.ColorToken.mint.opacity(0.3) : DS.ColorToken.purpleLight.opacity(0.3),
                                lineWidth: 1.5
                            )
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .opacity(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(hasCheckedInToday)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !hasCheckedInToday {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
        .accessibilityLabel(hasCheckedInToday ? "Checked in today" : "Check in today")
        .accessibilityHint(daysToNextMilestone > 0 ? "\(daysToNextMilestone) days until \(milestoneTitle)" : "")
    }
    
    #if canImport(ActivityKit)
    @available(iOS 18.0, *)
    private func updateLiveActivity() {
        Task { @MainActor in
            guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
            
            let attributes = SobrietyActivityAttributes(startDate: store.startDate)
            let contentState = SobrietyActivityAttributes.ContentState(
                currentStreak: store.currentStreak,
                daysToNextMilestone: daysToNextMilestone,
                milestoneTitle: milestoneTitle
            )
            
            let staleDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            let activityContent = ActivityContent(state: contentState, staleDate: staleDate)
            
            // Check if activity already exists
            let existingActivities = Activity<SobrietyActivityAttributes>.activities
            if let existingActivity = existingActivities.first(where: { 
                Calendar.current.isDate($0.attributes.startDate, inSameDayAs: store.startDate)
            }) {
                await existingActivity.update(activityContent)
            } else {
                // Start new activity
                do {
                    _ = try Activity<SobrietyActivityAttributes>.request(
                        attributes: attributes,
                        contentState: contentState,
                        pushType: nil
                    )
                } catch {
                    print("Failed to start Live Activity: \(error.localizedDescription)")
                }
            }
        }
    }
    #endif
}

// MARK: - Main Dashboard View
struct SobrietyDashboard: View {
    @EnvironmentObject var store: SobrietyStore
    @Binding var selectedTab: Int
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                DS.ColorToken.creamBG
                    .ignoresSafeArea(.all)
                
                // Content - VStack that fits without scrolling
                VStack(spacing: 0) {
                    // Header - compact
                    headerView
                        .padding(.horizontal, DS.Spacing.lg)
                        .padding(.top, geometry.safeAreaInsets.top > 0 ? DS.Spacing.xs : DS.Spacing.sm)
                        .padding(.bottom, DS.Spacing.sm)
                    
                    // Main content area - compact spacing
                    VStack(spacing: DS.Spacing.sm) {
                        // Compact streak visualization
                        CompactStreakView()
                            .padding(.horizontal, DS.Spacing.lg)
                        
                        // Merged check-in and milestone card
                        CheckInMilestoneCard()
                            .padding(.horizontal, DS.Spacing.lg)
                        
                        Spacer(minLength: 0)
                        
                        // Need Help button - positioned above tab bar
                        needHelpButton
                            .padding(.horizontal, DS.Spacing.lg)
                            .padding(.bottom, 8) // Space above tab bar
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Sober")
                .font(DS.FontToken.rounded(26, .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [DS.ColorToken.textPrimary, DS.ColorToken.textPrimary.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    // Shimmer effect
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.4), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .rotationEffect(.degrees(30))
                        .offset(x: shimmerOffset)
                        .mask(
                            Text("Sober")
                                .font(DS.FontToken.rounded(26, .bold))
                        )
                )
                .onAppear {
                    withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                        shimmerOffset = 200
                    }
                }
            
            Text("You've got this. One day at a time.")
                .font(DS.FontToken.rounded(13))
                .foregroundStyle(DS.ColorToken.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var needHelpButton: some View {
        NavigationLink(destination: CrisisResourcesView()) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .semibold))
                Text("Need Help?")
                    .font(DS.FontToken.rounded(16, .semibold))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.white)
                    .font(.system(size: 12, weight: .semibold))
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, 12)
            .frame(minHeight: 44)
            .background(DS.ColorToken.purpleGradient)
            .cornerRadius(DS.Radius.lg)
        }
        .accessibilityLabel("Open crisis resources")
    }
}

// MARK: - Preview with Mock Data
@MainActor
extension SobrietyStore {
    static func mockStore() -> SobrietyStore {
        let store = SobrietyStore()
        let oct30_2025 = Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 30)) ?? Date()
        // Override loaded data with mock data
        store.currentStreak = 1
        store.longestStreak = 1
        store.startDate = oct30_2025
        store.lastCheckInDate = oct30_2025
        store.checkInDates = [oct30_2025]
        store.milestones = []
        return store
    }
}

#Preview("iPhone SE") {
    let mockStore = SobrietyStore.mockStore()
    
    return NavigationView {
        SobrietyDashboard(selectedTab: .constant(0))
            .environmentObject(mockStore)
    }
}

#Preview("iPhone 15 Pro") {
    let mockStore = SobrietyStore.mockStore()
    
    return NavigationView {
        SobrietyDashboard(selectedTab: .constant(0))
            .environmentObject(mockStore)
    }
}

#Preview("iPhone 15 Pro Max") {
    let mockStore = SobrietyStore.mockStore()
    
    return NavigationView {
        SobrietyDashboard(selectedTab: .constant(0))
            .environmentObject(mockStore)
    }
}

#Preview("Dark Mode") {
    let mockStore = SobrietyStore.mockStore()
    
    return NavigationView {
        SobrietyDashboard(selectedTab: .constant(0))
            .environmentObject(mockStore)
            .preferredColorScheme(.dark)
    }
}
