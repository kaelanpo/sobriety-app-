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


