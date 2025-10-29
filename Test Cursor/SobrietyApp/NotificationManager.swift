import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func scheduleDailyCheckIn() {
        let content = UNMutableNotificationContent()
        content.title = "Daily Check-In"
        content.body = "Don't forget to check in and maintain your sobriety streak! 💪"
        content.sound = .default
        content.badge = 1
        
        // Schedule for 9 AM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-checkin", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
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
