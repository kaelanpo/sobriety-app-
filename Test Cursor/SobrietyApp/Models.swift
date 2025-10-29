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

// MARK: - Export Data Model
struct ExportData: Codable {
    let exportDate: Date
    let currentStreak: Int
    let longestStreak: Int
    let startDate: Date
    let lastRelapseDate: Date?
    let milestones: [Milestone]
    let habits: [Habit]
    let appVersion: String
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let fileNameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }()
}


