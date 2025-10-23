import Foundation
import SwiftUI
import Combine

// MARK: - Sobriety Store
@MainActor
final class SobrietyStore: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var startDate: Date = Date()
    @Published var lastRelapseDate: Date? = nil
    @Published var milestones: [Milestone] = []
    @Published var motivationalQuotes: [String] = [
        "Every day is a new beginning.",
        "You are stronger than you think.",
        "Recovery is not about perfection, it's about progress.",
        "Each day clean is a victory worth celebrating.",
        "Your future self will thank you for today's choices.",
        "Healing is not linear, but you're moving forward.",
        "You have the power to break free from addiction.",
        "Small steps lead to big changes.",
        "You are worthy of a healthy, fulfilling life.",
        "Every moment of resistance builds inner strength."
    ]
    
    private let streakKey = "sobriety_streak"
    private let longestStreakKey = "longest_streak"
    private let startDateKey = "start_date"
    private let lastRelapseKey = "last_relapse"
    private let milestonesKey = "milestones"
    
    init() {
        load()
        checkStreak()
    }
    
    func markRelapse() {
        lastRelapseDate = Date()
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        currentStreak = 0
        startDate = Date()
        save()
    }
    
    func checkStreak() {
        let calendar = Calendar.current
        let today = Date()
        
        // If this is a new day and no relapse has been marked, increment streak
        if calendar.isDate(startDate, inSameDayAs: today) {
            // Same day, don't increment
            return
        } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                  calendar.isDate(startDate, inSameDayAs: yesterday) {
            // Consecutive day, increment streak
            currentStreak += 1
            startDate = today
            checkMilestones()
            save()
        } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                  !calendar.isDate(startDate, inSameDayAs: today) && 
                  !calendar.isDate(startDate, inSameDayAs: yesterday) {
            // Gap in days detected, reset streak
            if currentStreak > longestStreak {
                longestStreak = currentStreak
            }
            currentStreak = 0
            startDate = today
            save()
        }
    }
    
    private func checkMilestones() {
        let milestoneDays = [1, 3, 7, 14, 30, 60, 90, 180, 365]
        
        for days in milestoneDays {
            if currentStreak == days && !milestones.contains(where: { $0.days == days }) {
                let milestone = Milestone(days: days, achievedDate: Date())
                milestones.append(milestone)
            }
        }
    }
    
    var currentMilestone: Milestone? {
        let milestoneDays = [1, 3, 7, 14, 30, 60, 90, 180, 365]
        let nextMilestone = milestoneDays.first { $0 > currentStreak }
        return nextMilestone.map { Milestone(days: $0, achievedDate: nil) }
    }
    
    var progressToNextMilestone: Double {
        guard let nextMilestone = currentMilestone else { return 1.0 }
        let milestoneDays = [1, 3, 7, 14, 30, 60, 90, 180, 365]
        let previousMilestone = milestoneDays.last { $0 <= currentStreak } ?? 0
        let totalProgress = nextMilestone.days - previousMilestone
        let currentProgress = currentStreak - previousMilestone
        return Double(currentProgress) / Double(totalProgress)
    }
    
    
    
    private func save() {
        UserDefaults.standard.set(currentStreak, forKey: streakKey)
        UserDefaults.standard.set(longestStreak, forKey: longestStreakKey)
        UserDefaults.standard.set(startDate, forKey: startDateKey)
        UserDefaults.standard.set(lastRelapseDate, forKey: lastRelapseKey)
        
        if let milestonesData = try? JSONEncoder().encode(milestones) {
            UserDefaults.standard.set(milestonesData, forKey: milestonesKey)
        }
        
    }
    
    private func load() {
        currentStreak = UserDefaults.standard.integer(forKey: streakKey)
        longestStreak = UserDefaults.standard.integer(forKey: longestStreakKey)
        startDate = UserDefaults.standard.object(forKey: startDateKey) as? Date ?? Date()
        lastRelapseDate = UserDefaults.standard.object(forKey: lastRelapseKey) as? Date
        
        if let milestonesData = UserDefaults.standard.data(forKey: milestonesKey),
           let decoded = try? JSONDecoder().decode([Milestone].self, from: milestonesData) {
            milestones = decoded
        }
        
    }
}
