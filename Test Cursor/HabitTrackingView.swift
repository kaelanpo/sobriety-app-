import SwiftUI

struct HabitTrackingView: View {
    @EnvironmentObject var store: SobrietyStore
    @State private var showingAddHabit = false
    @State private var newHabitName = ""
    @State private var newHabitCategory = HabitCategory.wellness
    
    // Sample habits for demonstration
    @State private var habits: [Habit] = [
        Habit(name: "Morning Meditation", category: .wellness, frequency: .daily, isCompleted: false),
        Habit(name: "Exercise", category: .fitness, frequency: .daily, isCompleted: false),
        Habit(name: "Read Recovery Literature", category: .education, frequency: .daily, isCompleted: false),
        Habit(name: "Call Sponsor", category: .support, frequency: .weekly, isCompleted: false),
        Habit(name: "Journal", category: .wellness, frequency: .daily, isCompleted: false)
    ]
    
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
                    .foregroundColor(DS.ColorToken.tint)
                }
            }
        }
        .sheet(isPresented: $showingAddHabit) {
            addHabitSheet
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
                .foregroundStyle(DS.ColorToken.tint)
            
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
                            .foregroundStyle(DS.ColorToken.tint)
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
        }
    }
    
    private func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
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

// MARK: - Habit Models
struct Habit: Identifiable, Codable {
    var id = UUID()
    let name: String
    let category: HabitCategory
    let frequency: HabitFrequency
    var isCompleted: Bool
    let createdAt: Date
    
    init(name: String, category: HabitCategory, frequency: HabitFrequency, isCompleted: Bool = false, createdAt: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.frequency = frequency
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}

enum HabitCategory: String, CaseIterable, Codable {
    case wellness = "Wellness"
    case fitness = "Fitness"
    case education = "Education"
    case support = "Support"
    case spirituality = "Spirituality"
    case creativity = "Creativity"
    case social = "Social"
    case other = "Other"
    
    var emoji: String {
        switch self {
        case .wellness: return "🧘"
        case .fitness: return "💪"
        case .education: return "📚"
        case .support: return "🤝"
        case .spirituality: return "🙏"
        case .creativity: return "🎨"
        case .social: return "👥"
        case .other: return "⭐"
        }
    }
}

enum HabitFrequency: String, CaseIterable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
}
