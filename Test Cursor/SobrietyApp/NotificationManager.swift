import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: - Simple async wrappers (iOS 16+)
    static func requestPermissions() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }
    
    static func scheduleDailyReminder(hour: Int = 9, minute: Int = 0, id: String = "daily-checkin") async {
        let content = UNMutableNotificationContent()
        content.title = "Daily Check-In"
        content.body = "Don't forget to check in and maintain your sobriety streak! 💪"
        content.sound = .default
        content.badge = 1
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        do { try await UNUserNotificationCenter.current().add(request) } catch { }
    }
    
    static func cancelReminder(id: String = "daily-checkin") {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func scheduleMilestoneReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Milestone Alert! 🎉"
        content.body = "You're approaching a major milestone in your recovery journey!"
        content.sound = .default
        
        // Schedule for tomorrow at 8 AM
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "milestone-reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling milestone notification: \(error)")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
