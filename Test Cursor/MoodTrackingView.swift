import SwiftUI

struct MoodTrackingView: View {
    @EnvironmentObject var store: SobrietyStore
    @State private var showingMoodEntry = false
    @State private var selectedMood: MoodLevel = .okay
    @State private var selectedEnergy: EnergyLevel = .moderate
    @State private var selectedStress: StressLevel = .moderate
    @State private var notes = ""
    @State private var selectedTriggers: Set<Trigger> = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DS.Spacing.lg) {
                    header
                    
                    if store.moodEntries.isEmpty {
                        emptyState
                    } else {
                        recentEntries
                        moodChart
                    }
                }
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.bottom, DS.Spacing.xl)
            }
            .background(DS.ColorToken.creamBG.ignoresSafeArea(.all))
            .navigationTitle("Mood Tracking")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Entry") {
                        showingMoodEntry = true
                    }
                    .foregroundColor(DS.ColorToken.tint)
                }
            }
        }
        .sheet(isPresented: $showingMoodEntry) {
            moodEntrySheet
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("How are you feeling?")
                .font(DS.FontToken.rounded(28, .bold))
                .foregroundStyle(DS.ColorToken.textPrimary)
            
            Text("Track your mood to understand patterns")
                .font(DS.FontToken.rounded(16))
                .foregroundStyle(DS.ColorToken.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, DS.Spacing.lg)
    }
    
    private var emptyState: some View {
        VStack(spacing: DS.Spacing.lg) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 60))
                .foregroundStyle(DS.ColorToken.tint)
            
            Text("No mood entries yet")
                .font(DS.FontToken.rounded(20, .semibold))
                .foregroundStyle(DS.ColorToken.textPrimary)
            
            Text("Start tracking your mood to see patterns and insights")
                .font(DS.FontToken.rounded(16))
                .foregroundStyle(DS.ColorToken.textSecondary)
                .multilineTextAlignment(.center)
            
            Button("Add First Entry") {
                showingMoodEntry = true
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.top, DS.Spacing.xl)
    }
    
    private var recentEntries: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Recent Entries")
                .font(DS.FontToken.rounded(18, .semibold))
                .foregroundStyle(DS.ColorToken.textPrimary)
            
            LazyVStack(spacing: DS.Spacing.sm) {
                ForEach(store.moodEntries.prefix(5)) { entry in
                    MoodEntryCard(entry: entry)
                }
            }
        }
    }
    
    private var moodChart: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Mood Trend")
                .font(DS.FontToken.rounded(18, .semibold))
                .foregroundStyle(DS.ColorToken.textPrimary)
            
            SoftCard {
                VStack(spacing: DS.Spacing.md) {
                    if store.moodEntries.count >= 2 {
                        SimpleMoodChart(entries: Array(store.moodEntries.prefix(7)))
                    } else {
                        Text("Add more entries to see your mood trend")
                            .font(DS.FontToken.rounded(14))
                            .foregroundStyle(DS.ColorToken.textSecondary)
                            .padding(.vertical, DS.Spacing.lg)
                    }
                }
            }
        }
    }
    
    private var moodEntrySheet: some View {
        NavigationView {
            Form {
                Section("How are you feeling?") {
                    Picker("Mood", selection: $selectedMood) {
                        ForEach(MoodLevel.allCases, id: \.self) { mood in
                            HStack {
                                Text(mood.emoji)
                                Text(mood.rawValue)
                            }
                            .tag(mood)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Energy Level") {
                    Picker("Energy", selection: $selectedEnergy) {
                        ForEach(EnergyLevel.allCases, id: \.self) { energy in
                            HStack {
                                Text(energy.emoji)
                                Text(energy.rawValue)
                            }
                            .tag(energy)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Stress Level") {
                    Picker("Stress", selection: $selectedStress) {
                        ForEach(StressLevel.allCases, id: \.self) { stress in
                            HStack {
                                Text(stress.emoji)
                                Text(stress.rawValue)
                            }
                            .tag(stress)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Triggers (Optional)") {
                    ForEach(Trigger.allCases, id: \.self) { trigger in
                        HStack {
                            Text(trigger.emoji)
                            Text(trigger.rawValue)
                            Spacer()
                            if selectedTriggers.contains(trigger) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(DS.ColorToken.tint)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedTriggers.contains(trigger) {
                                selectedTriggers.remove(trigger)
                            } else {
                                selectedTriggers.insert(trigger)
                            }
                        }
                    }
                }
                
                Section("Notes (Optional)") {
                    TextField("How are you feeling today?", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Mood Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingMoodEntry = false
                        resetForm()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let entry = MoodEntry(
                            mood: selectedMood,
                            energy: selectedEnergy,
                            stress: selectedStress,
                            notes: notes,
                            triggers: Array(selectedTriggers)
                        )
                        store.addMoodEntry(entry)
                        showingMoodEntry = false
                        resetForm()
                    }
                }
            }
        }
    }
    
    private func resetForm() {
        selectedMood = .okay
        selectedEnergy = .moderate
        selectedStress = .moderate
        notes = ""
        selectedTriggers = []
    }
}

struct MoodEntryCard: View {
    let entry: MoodEntry
    
    var body: some View {
        SoftCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(entry.mood.emoji)
                            .font(.title2)
                        Text(entry.mood.rawValue)
                            .font(DS.FontToken.rounded(16, .semibold))
                            .foregroundStyle(DS.ColorToken.textPrimary)
                    }
                    
                    Text(entry.date, style: .relative)
                        .font(DS.FontToken.rounded(12))
                        .foregroundStyle(DS.ColorToken.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 8) {
                        HStack(spacing: 2) {
                            Image(systemName: "bolt.fill")
                                .font(.caption)
                            Text(entry.energy.rawValue)
                                .font(DS.FontToken.rounded(12))
                        }
                        .foregroundStyle(DS.ColorToken.textSecondary)
                        
                        HStack(spacing: 2) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                            Text(entry.stress.rawValue)
                                .font(DS.FontToken.rounded(12))
                        }
                        .foregroundStyle(DS.ColorToken.textSecondary)
                    }
                    
                    if !entry.triggers.isEmpty {
                        HStack {
                            ForEach(entry.triggers.prefix(2), id: \.self) { trigger in
                                Text(trigger.emoji)
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SimpleMoodChart: View {
    let entries: [MoodEntry]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(entries.reversed(), id: \.id) { entry in
                VStack(spacing: 2) {
                    Rectangle()
                        .fill(entry.mood.color)
                        .frame(width: 20, height: CGFloat(entry.mood.value) * 8)
                        .cornerRadius(2)
                    
                    Text(entry.date, format: .dateTime.day().month(.abbreviated))
                        .font(.caption2)
                        .foregroundStyle(DS.ColorToken.textSecondary)
                }
            }
        }
        .frame(height: 80)
    }
}
