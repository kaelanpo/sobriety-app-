import SwiftUI
#if os(iOS)
import UIKit
#endif

// Custom shape for rounded bottom corners only
struct RoundedBottomCorners: Shape {
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Start from top-left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        // Top edge
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        // Top-right corner (sharp)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        // Bottom-right corner (rounded)
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - radius, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        // Bottom edge
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        // Bottom-left corner (rounded)
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - radius),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        // Left edge
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        
        return path
    }
}

struct HabitTrackingView: View {
    @EnvironmentObject var store: SobrietyStore
    @State private var showingAddHabit = false
    @State private var newHabitName = ""
    @State private var newHabitCategory = HabitCategory.wellness
    @State private var newHabitFrequency = HabitFrequency.daily
    @State private var showToast = false
    @State private var lastCompletedHabitName = ""
    
    // Persistent habits storage
    @State private var habits: [Habit] = []
    private let habitsKey = "user_habits"
    private let lastResetDateKey = "habits_last_reset_date"
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        heroHeader
                        
                        if habits.isEmpty {
                            emptyState
                        } else {
                            dailyMilestones
                            progressHub
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                    .padding(.top, 12)
                }
            }
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        #if os(iOS)
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        #endif
                        showingAddHabit = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(hex: "#BA68C8"))
                            .frame(width: 32, height: 32)
                            .background {
                                Circle()
                                    .fill(Color(hex: "#BA68C8").opacity(0.12))
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .overlay(alignment: .bottom) {
                if showToast {
                    Text("Achievement Unlocked! +10 Recovery Points")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(Color(hex: "#BA68C8").opacity(0.9))
                                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                        )
                        .padding(.bottom, 100)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: showToast)
                }
            }
        }
        .sheet(isPresented: $showingAddHabit) {
            addHabitSheet
        }
        .onAppear {
            loadHabits()
            checkAndResetHabits()
        }
        .onChange(of: habits) { _ in
            checkAndResetHabits()
        }
    }
    
    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Recovery")
                .font(.title3.weight(.semibold))
            
            Text("Small wins add up. Track what matters each day.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.orange)
                Text("\(store.currentStreak)-day streak")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color(uiColor: .separator).opacity(0.15))
        )
    }
    
    private var emptyState: some View {
        VStack(spacing: DS.Spacing.lg) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundStyle(DS.ColorToken.purpleGradient)
            
            Text("No goals set yet")
                .font(DS.FontToken.rounded(20, .semibold))
                .foregroundStyle(DS.ColorToken.textPrimary)
            
            Text("Add your first recovery goal to get started")
                .font(DS.FontToken.rounded(16))
                .foregroundStyle(DS.ColorToken.textSecondary)
                .multilineTextAlignment(.center)
            
            Button("Add First Goal") {
                showingAddHabit = true
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.top, DS.Spacing.xl)
    }
    
    private var dailyMilestones: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Milestones")
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 8) {
                ForEach(dailyHabits) { habit in
                    HabitAchievementCard(habit: habit) {
                        let wasCompleted = habit.isCompleted
                        toggleHabit(habit)
                        // Show toast if just completed
                        if !wasCompleted, let updatedHabit = habits.first(where: { $0.id == habit.id }), updatedHabit.isCompleted {
                            lastCompletedHabitName = habit.name
                            showToast = true
                            // Auto-dismiss after 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showToast = false
                            }
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button("Delete", role: .destructive) {
                            deleteHabit(habit)
                        }
                    }
                }
            }
        }
    }
    
    private var progressHub: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress")
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color(uiColor: .systemGray5), lineWidth: 8)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(weeklyProgress))
                        .stroke(
                            Color(hex: "#4DB6AC"),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.6), value: weeklyProgress)
                    
                    VStack(spacing: 2) {
                        Text("\(completedThisWeek)")
                            .font(.title3.weight(.semibold))
                        Text("completed")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 120, height: 120)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total goals")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(habits.count)")
                            .font(.subheadline.weight(.semibold))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Weekly progress")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(Int(weeklyProgress * 100))%")
                            .font(.subheadline.weight(.semibold))
                    }
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color(uiColor: .separator).opacity(0.1))
            )
        }
    }
    
    private var addHabitSheet: some View {
        NavigationStack {
            ZStack {
                // Background gradient matching main page
                LinearGradient(
                    colors: [Color(hex: "#FDFAF6"), Color(hex: "#E8F5E9")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Subtle holographic overlay
                RadialGradient(
                    colors: [Color(hex: "#BA68C8").opacity(0.1), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 300
                )
                .opacity(0.05)
                .ignoresSafeArea()
                
                Form {
                    Section {
                        // Goal Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Goal Name")
                                .font(.subheadline.bold())
                                .foregroundStyle(.secondary)
                            
                            TextField("e.g., Morning Meditation", text: $newHabitName)
                                .font(.body)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                        .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 8, trailing: 0))
                        
                        // Category Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.subheadline.bold())
                                .foregroundStyle(.secondary)
                            
                            Picker("Category", selection: $newHabitCategory) {
                                ForEach(HabitCategory.allCases, id: \.self) { category in
                                    HStack {
                                        Text(category.emoji)
                                        Text(category.rawValue)
                                    }
                                    .tag(category)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(Color(hex: "#BA68C8"))
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        
                        // Frequency Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Frequency")
                                .font(.subheadline.bold())
                                .foregroundStyle(.secondary)
                            
                            Picker("Frequency", selection: $newHabitFrequency) {
                                ForEach(HabitFrequency.allCases, id: \.self) { frequency in
                                    Text(frequency.rawValue).tag(frequency)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 12, trailing: 0))
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismissAddGoalSheet()
                    }
                    .tint(.gray)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addNewGoal()
                    }
                    .font(.body.bold())
                    .tint(Color(hex: "#BA68C8"))
                    .disabled(newHabitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    private func dismissAddGoalSheet() {
        showingAddHabit = false
        newHabitName = ""
        newHabitFrequency = .daily
        newHabitCategory = .wellness
    }
    
    private func addNewGoal() {
        let habit = Habit(
            name: newHabitName,
            category: newHabitCategory,
            frequency: newHabitFrequency,
            isCompleted: false
        )
        habits.append(habit)
        saveHabits()
        
        // Haptic feedback
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
        
        dismissAddGoalSheet()
    }
    
    private var dailyHabits: [Habit] {
        habits.filter { $0.frequency == .daily }
    }
    
    private var completedHabitsCount: Int {
        habits.filter { $0.isCompleted }.count
    }
    
    private var completedThisWeek: Int {
        habits.filter { $0.isCompleted }.count
    }
    
    private var weeklyProgress: Double {
        guard !habits.isEmpty else { return 0.0 }
        return Double(completedThisWeek) / Double(habits.count)
    }
    
    private func toggleHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                habits[index].isCompleted.toggle()
            }
            // Haptic feedback
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            #endif
            saveHabits()
        }
    }
    
    // MARK: - Reset Logic
    private func checkAndResetHabits() {
        let calendar = Calendar.current
        let now = Date()
        
        // Get last reset date
        let lastResetDate = UserDefaults.standard.object(forKey: lastResetDateKey) as? Date ?? now
        
        // Check if we need to reset daily habits
        if !calendar.isDate(lastResetDate, inSameDayAs: now) {
            // Reset daily habits
            for index in habits.indices {
                if habits[index].frequency == .daily {
                    habits[index].isCompleted = false
                }
            }
            
            // Check if we need to reset weekly habits (new week)
            if !calendar.isDate(lastResetDate, equalTo: now, toGranularity: .weekOfYear) {
                for index in habits.indices {
                    if habits[index].frequency == .weekly {
                        habits[index].isCompleted = false
                    }
                }
            }
            
            // Update last reset date
            UserDefaults.standard.set(now, forKey: lastResetDateKey)
            saveHabits()
        }
    }
    
    private func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        saveHabits()
    }
    
    // MARK: - Persistence Methods
    private func loadHabits() {
        do {
            if let habitsData = UserDefaults.standard.data(forKey: habitsKey) {
                let decodedHabits = try JSONDecoder().decode([Habit].self, from: habitsData)
                habits = decodedHabits
            } else {
                // Load default habits for first-time users
                loadDefaultHabits()
            }
        } catch {
            print("Error loading habits: \(error.localizedDescription)")
            // Load default habits as fallback
            loadDefaultHabits()
        }
    }
    
    private func loadDefaultHabits() {
        habits = [
            Habit(name: "Morning Meditation", category: .wellness, frequency: .daily, isCompleted: false),
            Habit(name: "Exercise", category: .fitness, frequency: .daily, isCompleted: false),
            Habit(name: "Read Recovery Literature", category: .education, frequency: .daily, isCompleted: false),
            Habit(name: "Journal", category: .wellness, frequency: .daily, isCompleted: false),
            Habit(name: "Call Sponsor", category: .support, frequency: .weekly, isCompleted: false)
        ]
        saveHabits()
    }
    
    private func saveHabits() {
        do {
            let habitsData = try JSONEncoder().encode(habits)
            UserDefaults.standard.set(habitsData, forKey: habitsKey)
            
            if !UserDefaults.standard.synchronize() {
                print("Warning: Failed to synchronize habits data")
            }
        } catch {
            print("Error saving habits: \(error.localizedDescription)")
        }
    }
}

struct HabitAchievementCard: View {
    let habit: Habit
    let onToggle: () -> Void
    @State private var scale: CGFloat = 1.0
    
    private var accentColor: Color {
        Color(hex: "#4DB6AC")
    }
    
    var body: some View {
        Button(action: {
            onToggle()
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                scale = 0.97
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    scale = 1.0
                }
            }
            
            if !habit.isCompleted {
                #if os(iOS)
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                #endif
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                    .imageScale(.large)
                    .fontWeight(.semibold)
                    .foregroundStyle(habit.isCompleted ? accentColor : Color(.systemGray3))
                    .scaleEffect(habit.isCompleted ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: habit.isCompleted)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(habit.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Text("\(habit.category.rawValue) · \(habit.frequency.rawValue)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(habit.category.emoji)
                    .font(.title3)
                    .accessibility(hidden: true)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        habit.isCompleted ? accentColor.opacity(0.35) : Color(.systemGray5),
                        lineWidth: habit.isCompleted ? 1.5 : 1
                    )
            )
            .scaleEffect(scale)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

