import SwiftUI

struct HabitTrackingView: View {
    @EnvironmentObject var store: SobrietyStore
    @State private var showingAddHabit = false
    @State private var newHabitName = ""
    @State private var newHabitCategory = HabitCategory.wellness
    
    // Persistent habits storage
    @State private var habits: [Habit] = []
    private let habitsKey = "user_habits"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DS.Spacing.lg) {
                    header
                    
                    if habits.isEmpty {
                        emptyState
                    } else {
                        todayHabits
                        weeklyHabits
                        habitStats
                    }
                }
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.bottom, DS.Spacing.xl)
            }
            .background(DS.ColorToken.creamBG.ignoresSafeArea(.all))
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Goal") {
                        showingAddHabit = true
                    }
                    .foregroundStyle(DS.ColorToken.purpleGradient)
                }
            }
        }
        .sheet(isPresented: $showingAddHabit) {
            addHabitSheet
        }
        .onAppear {
            loadHabits()
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("Your Recovery Goals")
                .font(DS.FontToken.rounded(28, .bold))
                .foregroundStyle(DS.ColorToken.textPrimary)
            
            Text("Build healthy habits to support your journey")
                .font(DS.FontToken.rounded(16))
                .foregroundStyle(DS.ColorToken.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, DS.Spacing.lg)
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
    
    private var todayHabits: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Today's Goals")
                .font(DS.FontToken.rounded(18, .semibold))
                .foregroundStyle(DS.ColorToken.textPrimary)
            
            LazyVStack(spacing: DS.Spacing.sm) {
                ForEach(dailyHabits) { habit in
                    HabitCard(habit: habit) {
                        toggleHabit(habit)
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
    
    private var weeklyHabits: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Weekly Goals")
                .font(DS.FontToken.rounded(18, .semibold))
                .foregroundStyle(DS.ColorToken.textPrimary)
            
            LazyVStack(spacing: DS.Spacing.sm) {
                ForEach(weeklyHabitsList) { habit in
                    HabitCard(habit: habit) {
                        toggleHabit(habit)
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
    
    private var habitStats: some View {
        SoftCard {
            VStack(spacing: DS.Spacing.md) {
                Text("This Week's Progress")
                    .font(DS.FontToken.rounded(18, .semibold))
                    .foregroundStyle(DS.ColorToken.textPrimary)
                
                HStack(spacing: DS.Spacing.lg) {
                    VStack {
                        Text("\(completedHabitsCount)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(DS.ColorToken.purpleGradient)
                        Text("Completed")
                            .font(DS.FontToken.rounded(12))
                            .foregroundStyle(DS.ColorToken.textSecondary)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("\(habits.count)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(DS.ColorToken.mint)
                        Text("Total Goals")
                            .font(DS.FontToken.rounded(12))
                            .foregroundStyle(DS.ColorToken.textSecondary)
                    }
                }
            }
        }
    }
    
    private var addHabitSheet: some View {
        NavigationView {
            Form {
                Section("Goal Details") {
                    TextField("Goal name", text: $newHabitName)
                        .font(DS.FontToken.rounded(16))
                    
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
                }
            }
            .navigationTitle("Add Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingAddHabit = false
                        newHabitName = ""
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let habit = Habit(
                            name: newHabitName,
                            category: newHabitCategory,
                            frequency: .daily,
                            isCompleted: false
                        )
                        habits.append(habit)
                        saveHabits()
                        showingAddHabit = false
                        newHabitName = ""
                    }
                    .disabled(newHabitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private var dailyHabits: [Habit] {
        habits.filter { $0.frequency == .daily }
    }
    
    private var weeklyHabitsList: [Habit] {
        habits.filter { $0.frequency == .weekly }
    }
    
    private var completedHabitsCount: Int {
        habits.filter { $0.isCompleted }.count
    }
    
    private func toggleHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].isCompleted.toggle()
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
            Habit(name: "Call Sponsor", category: .support, frequency: .weekly, isCompleted: false),
            Habit(name: "Journal", category: .wellness, frequency: .daily, isCompleted: false)
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

struct HabitCard: View {
    let habit: Habit
    let onToggle: () -> Void
    
    var body: some View {
        SoftCard {
            HStack {
                Button(action: onToggle) {
                    Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(habit.isCompleted ? DS.ColorToken.mint : DS.ColorToken.textSecondary.opacity(0.5))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(DS.FontToken.rounded(16, .semibold))
                        .foregroundStyle(DS.ColorToken.textPrimary)
                        .strikethrough(habit.isCompleted, color: DS.ColorToken.textSecondary)
                    
                    HStack {
                        Text(habit.category.emoji)
                        Text(habit.category.rawValue)
                            .font(DS.FontToken.rounded(12))
                            .foregroundStyle(DS.ColorToken.textSecondary)
                        
                        Spacer()
                        
                        Text(habit.frequency.rawValue)
                            .font(DS.FontToken.rounded(12))
                            .foregroundStyle(DS.ColorToken.textSecondary)
                    }
                }
                
                Spacer()
            }
        }
    }
}

