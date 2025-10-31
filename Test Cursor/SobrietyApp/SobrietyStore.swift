import Foundation
import SwiftUI
import Combine
import SwiftData

// MARK: - Sobriety Store
@MainActor
final class SobrietyStore: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var startDate: Date = Date()
    @Published var lastRelapseDate: Date? = nil
    @Published var lastCheckInDate: Date? = nil
    @Published var checkInDates: [Date] = []
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
    private let lastCheckInKey = "last_check_in"
    private let milestonesKey = "milestones"
    private let checkInDatesKey = "check_in_dates"
    
    init() {
        load()
        checkInDates = loadCheckInDates()
        checkStreak()
    }
    
    func markRelapse() {
        lastRelapseDate = Date()
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        currentStreak = 0
        startDate = Date()
        lastCheckInDate = nil
        save()
    }
    
    func checkIn() {
        let today = Calendar.current.startOfDay(for: Date())
        if !checkInDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
            checkInDates.append(today)
            saveCheckInDates(checkInDates)
            lastCheckInDate = today
            recomputeStreaks(from: checkInDates)
            checkMilestones()
            save()
        }
    }
    
    func checkStreak() {
        recomputeStreaks(from: checkInDates)
    }

    // MARK: - Streak computation
    func computeStreaks(referenceDate: Date, checkIns: [Date]) -> (current: Int, longest: Int) {
        let calendar = Calendar.current
        let uniqueDays = Set(checkIns.map { calendar.startOfDay(for: $0) })
        let sorted = uniqueDays.sorted()
        var longest = 0
        var current = 0
        var previousDay: Date?
        for day in sorted {
            if let prev = previousDay, calendar.dateComponents([.day], from: prev, to: day).day == 1 {
                current += 1
            } else {
                current = 1
            }
            longest = max(longest, current)
            previousDay = day
        }
        // Current streak is days ending at the latest day; if the latest day isn't today or yesterday, it may be broken.
        if let latest = sorted.last {
            if !calendar.isDate(latest, inSameDayAs: calendar.startOfDay(for: referenceDate)) &&
               calendar.dateComponents([.day], from: latest, to: referenceDate).day ?? 2 > 1 {
                // gap > 1 day after last check-in
                return (0, longest)
            }
        }
        return (current, longest)
    }

    private func recomputeStreaks(from dates: [Date]) {
        let result = computeStreaks(referenceDate: Date(), checkIns: dates)
        currentStreak = result.current
        longestStreak = max(longestStreak, result.longest)
        lastCheckInDate = dates.sorted().last
        if currentStreak == 1 { startDate = lastCheckInDate ?? Date() }
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
    
    var needsCheckIn: Bool {
        guard let last = checkInDates.sorted().last else { return true }
        return !Calendar.current.isDate(last, inSameDayAs: Date())
    }
    
    func hasCheckedInOnDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return checkInDates.contains(where: { calendar.isDate($0, inSameDayAs: date) })
    }
    
    
    
    private func save() {
        do {
            UserDefaults.standard.set(currentStreak, forKey: streakKey)
            UserDefaults.standard.set(longestStreak, forKey: longestStreakKey)
            UserDefaults.standard.set(startDate, forKey: startDateKey)
            UserDefaults.standard.set(lastRelapseDate, forKey: lastRelapseKey)
            UserDefaults.standard.set(lastCheckInDate, forKey: lastCheckInKey)
            
            let milestonesData = try JSONEncoder().encode(milestones)
            UserDefaults.standard.set(milestonesData, forKey: milestonesKey)
            
            // Verify data was saved correctly
            if !UserDefaults.standard.synchronize() {
                print("Warning: Failed to synchronize UserDefaults")
            }
        } catch {
            print("Error saving data: \(error.localizedDescription)")
        }
    }
    
    private func load() {
        do {
            currentStreak = UserDefaults.standard.integer(forKey: streakKey)
            longestStreak = UserDefaults.standard.integer(forKey: longestStreakKey)
            startDate = UserDefaults.standard.object(forKey: startDateKey) as? Date ?? Date()
            lastRelapseDate = UserDefaults.standard.object(forKey: lastRelapseKey) as? Date
            lastCheckInDate = UserDefaults.standard.object(forKey: lastCheckInKey) as? Date
            
            // Validate loaded data
            if currentStreak < 0 {
                print("Warning: Invalid streak data, resetting to 0")
                currentStreak = 0
            }
            
            if longestStreak < 0 {
                print("Warning: Invalid longest streak data, resetting to 0")
                longestStreak = 0
            }
            
            if let milestonesData = UserDefaults.standard.data(forKey: milestonesKey) {
                let decoded = try JSONDecoder().decode([Milestone].self, from: milestonesData)
                milestones = decoded
            } else {
                milestones = []
            }
            // Recompute streaks from stored check-in dates if present
            let dates = loadCheckInDates()
            recomputeStreaks(from: dates)
        } catch {
            print("Error loading data: \(error.localizedDescription)")
            // Reset to safe defaults
            currentStreak = 0
            longestStreak = 0
            startDate = Date()
            lastRelapseDate = nil
            milestones = []
        }
    }

    // MARK: - Check-in dates persistence
    private func loadCheckInDates() -> [Date] {
        guard let data = UserDefaults.standard.data(forKey: checkInDatesKey),
              let decoded = try? JSONDecoder().decode([Date].self, from: data) else { return [] }
        return decoded
    }
    
    private func saveCheckInDates(_ dates: [Date]) {
        if let data = try? JSONEncoder().encode(dates) {
            UserDefaults.standard.set(data, forKey: checkInDatesKey)
        }
    }
}
