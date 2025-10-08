import Foundation
import SwiftUI

// MARK: - Data Models

struct Milestone: Identifiable, Codable {
    var id = UUID()
    let days: Int
    let achievedDate: Date?
    
    init(days: Int, achievedDate: Date? = nil) {
        self.id = UUID()
        self.days = days
        self.achievedDate = achievedDate
    }
    
    var title: String {
        switch days {
        case 1: return "First Day"
        case 3: return "Three Days Strong"
        case 7: return "One Week"
        case 14: return "Two Weeks"
        case 30: return "One Month"
        case 60: return "Two Months"
        case 90: return "Three Months"
        case 180: return "Six Months"
        case 365: return "One Year"
        default: return "\(days) Days"
        }
    }
    
    var description: String {
        switch days {
        case 1: return "You took the first step!"
        case 3: return "Building momentum!"
        case 7: return "One week of freedom!"
        case 14: return "Two weeks of strength!"
        case 30: return "A full month clean!"
        case 60: return "Two months of progress!"
        case 90: return "Three months of healing!"
        case 180: return "Half a year strong!"
        case 365: return "A full year of recovery!"
        default: return "Amazing progress!"
        }
    }
    
    var icon: String {
        switch days {
        case 1: return "star.fill"
        case 3: return "flame.fill"
        case 7: return "trophy.fill"
        case 14: return "medal.fill"
        case 30: return "crown.fill"
        case 60: return "diamond.fill"
        case 90: return "gem.fill"
        case 180: return "star.circle.fill"
        case 365: return "rosette"
        default: return "checkmark.seal.fill"
        }
    }
}

// MARK: - Mood Tracking Models

struct MoodEntry: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let mood: MoodLevel
    let energy: EnergyLevel
    let stress: StressLevel
    let notes: String
    let triggers: [Trigger]
    
    init(date: Date = Date(), mood: MoodLevel, energy: EnergyLevel, stress: StressLevel, notes: String = "", triggers: [Trigger] = []) {
        self.id = UUID()
        self.date = date
        self.mood = mood
        self.energy = energy
        self.stress = stress
        self.notes = notes
        self.triggers = triggers
    }
}

enum MoodLevel: String, CaseIterable, Codable {
    case terrible = "Terrible"
    case bad = "Bad"
    case okay = "Okay"
    case good = "Good"
    case excellent = "Excellent"
    
    var emoji: String {
        switch self {
        case .terrible: return "😢"
        case .bad: return "😔"
        case .okay: return "😐"
        case .good: return "😊"
        case .excellent: return "🤩"
        }
    }
    
    var color: Color {
        switch self {
        case .terrible: return .red
        case .bad: return .orange
        case .okay: return .yellow
        case .good: return .green
        case .excellent: return .blue
        }
    }
    
    var value: Int {
        switch self {
        case .terrible: return 1
        case .bad: return 2
        case .okay: return 3
        case .good: return 4
        case .excellent: return 5
        }
    }
}

enum EnergyLevel: String, CaseIterable, Codable {
    case veryLow = "Very Low"
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case veryHigh = "Very High"
    
    var emoji: String {
        switch self {
        case .veryLow: return "🔋"
        case .low: return "🔋"
        case .moderate: return "🔋"
        case .high: return "⚡"
        case .veryHigh: return "⚡"
        }
    }
    
    var value: Int {
        switch self {
        case .veryLow: return 1
        case .low: return 2
        case .moderate: return 3
        case .high: return 4
        case .veryHigh: return 5
        }
    }
}

enum StressLevel: String, CaseIterable, Codable {
    case veryLow = "Very Low"
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case veryHigh = "Very High"
    
    var emoji: String {
        switch self {
        case .veryLow: return "😌"
        case .low: return "🙂"
        case .moderate: return "😐"
        case .high: return "😰"
        case .veryHigh: return "😱"
        }
    }
    
    var value: Int {
        switch self {
        case .veryLow: return 1
        case .low: return 2
        case .moderate: return 3
        case .high: return 4
        case .veryHigh: return 5
        }
    }
}

enum Trigger: String, CaseIterable, Codable {
    case stress = "Stress"
    case loneliness = "Loneliness"
    case boredom = "Boredom"
    case celebration = "Celebration"
    case social = "Social Pressure"
    case work = "Work Pressure"
    case relationship = "Relationship Issues"
    case financial = "Financial Stress"
    case health = "Health Issues"
    case other = "Other"
    
    var emoji: String {
        switch self {
        case .stress: return "😰"
        case .loneliness: return "😔"
        case .boredom: return "😴"
        case .celebration: return "🎉"
        case .social: return "👥"
        case .work: return "💼"
        case .relationship: return "💔"
        case .financial: return "💰"
        case .health: return "🏥"
        case .other: return "❓"
        }
    }
}
