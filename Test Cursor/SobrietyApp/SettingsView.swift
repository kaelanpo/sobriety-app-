import SwiftUI
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject var store: SobrietyStore
    @State private var showingRelapseConfirmation = false
    @State private var showingResetConfirmation = false
    @State private var notificationsOn: Bool = UserDefaults.standard.bool(forKey: "notifications_enabled")
    @State private var notificationsError: String? = nil
    
    var body: some View {
        NavigationView {
            List {
                profileSection
                dataSection
                notificationSection
                supportSection
                aboutSection
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
            .background(DS.ColorToken.creamBG.ignoresSafeArea(.all))
        }
        .confirmationDialog(
            "Mark Relapse",
            isPresented: $showingRelapseConfirmation,
            titleVisibility: .visible
        ) {
            Button("Yes, I relapsed", role: .destructive) {
                store.markRelapse()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will reset your current streak to 0. Remember, recovery is a journey and setbacks are part of the process.")
        }
        .confirmationDialog(
            "Reset All Data",
            isPresented: $showingResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset Everything", role: .destructive) {
                resetAllData()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete all your data including streaks and milestones. This action cannot be undone.")
        }
    }
    
    private var profileSection: some View {
        Section {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(DS.ColorToken.purpleGradient)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recovery Journey")
                        .font(DS.FontToken.rounded(18, .semibold))
                        .foregroundStyle(DS.ColorToken.textPrimary)
                    
                    Text("\(store.currentStreak) days clean")
                        .font(DS.FontToken.rounded(14))
                        .foregroundStyle(DS.ColorToken.textSecondary)
                }
                
                Spacer()
            }
            .padding(.vertical, DS.Spacing.sm)
        }
    }
    
    private var dataSection: some View {
        Section("Data Management") {
            Button("Mark Relapse") {
                showingRelapseConfirmation = true
            }
            .foregroundColor(.red)
            
            Button("Reset All Data") {
                showingResetConfirmation = true
            }
            .foregroundColor(.red)
            
            NavigationLink("Export Data") {
                ExportDataView()
            }
        }
    }
    
    private var supportSection: some View {
        Section("Support & Resources") {
            NavigationLink("Crisis Resources") {
                CrisisResourcesView()
            }
            
            NavigationLink("Recovery Resources") {
                RecoveryResourcesView()
            }
            
            Button("Contact Support") {
                contactSupport()
            }
        }
    }
    
    private var notificationSection: some View {
        Section("Notifications") {
            Toggle("Daily Check-In Reminders", isOn: $notificationsOn)
                .onChange(of: notificationsOn) { newValue in
                    UserDefaults.standard.set(newValue, forKey: "notifications_enabled")
                    Task {
                        if newValue {
                            let granted = await requestNotificationPermissions()
                            if granted {
                                await scheduleDailyReminder(hour: 9, minute: 0)
                                notificationsError = nil
                            } else {
                                notificationsOn = false
                                notificationsError = "Notifications permission denied."
                            }
                        } else {
                            cancelDailyReminder()
                            notificationsError = nil
                        }
                    }
                }
            if let error = notificationsError {
                Text(error)
                    .font(DS.FontToken.rounded(12))
                    .foregroundStyle(.red)
            }
        }
    }
    
    // MARK: - Local notification helpers (kept here since project doesn't yet include shared manager in target)
    private func requestNotificationPermissions() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch { return false }
    }
    
    private func scheduleDailyReminder(hour: Int, minute: Int, id: String = "daily-checkin") async {
        let content = UNMutableNotificationContent()
        content.title = "Daily Check-In"
        content.body = "Tap to open the app and log today."
        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let req = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        _ = try? await UNUserNotificationCenter.current().add(req)
    }
    
    private func cancelDailyReminder(id: String = "daily-checkin") {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(DS.ColorToken.textSecondary)
            }
            
            HStack {
                Text("Build")
                Spacer()
                Text("1")
                    .foregroundStyle(DS.ColorToken.textSecondary)
            }
            
            NavigationLink("Privacy Policy") {
                PrivacyPolicyView()
            }
            
            NavigationLink("Terms of Service") {
                TermsOfServiceView()
            }
        }
    }
    
    private func resetAllData() {
        store.currentStreak = 0
        store.longestStreak = 0
        store.startDate = Date()
        store.lastRelapseDate = nil
        store.milestones = []
    }
    
    private func contactSupport() {
        let supportEmail = "support@sobrietyapp.com"
        let subject = "Sobriety App Support Request"
        let body = """
        Hi there,
        
        I need help with the Sobriety App. Here are my details:
        
        Current Streak: \(store.currentStreak) days
        Longest Streak: \(store.longestStreak) days
        App Version: 1.0.0
        
        Please describe your issue or question below:
        
        
        """
        
        if let url = URL(string: "mailto:\(supportEmail)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            UIApplication.shared.open(url)
        }
    }
}

struct ExportDataView: View {
    @EnvironmentObject var store: SobrietyStore
    
    var body: some View {
        VStack(spacing: DS.Spacing.lg) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 60))
                .foregroundStyle(DS.ColorToken.purpleGradient)
            
            Text("Export Your Data")
                .font(DS.FontToken.rounded(24, .bold))
                .foregroundStyle(DS.ColorToken.textPrimary)
            
            Text("Export your recovery data to share with your support team or keep as a backup")
                .font(DS.FontToken.rounded(16))
                .foregroundStyle(DS.ColorToken.textSecondary)
                .multilineTextAlignment(.center)
            
            Button("Export Data") {
                exportData()
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Spacer()
        }
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.top, DS.Spacing.xl)
        .background(DS.ColorToken.creamBG.ignoresSafeArea(.all))
        .navigationTitle("Export Data")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func exportData() {
        // Create comprehensive data export
        let exportData = createExportData()
        
        // Convert to JSON
        guard let jsonData = try? JSONEncoder().encode(exportData),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("Failed to encode data for export")
            return
        }
        
        // Create file URL
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "sobriety_data_\(DateFormatter.fileNameFormatter.string(from: Date())).json"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        do {
            try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
            shareFile(fileURL)
        } catch {
            print("Failed to write export file: \(error)")
        }
    }
    
    private func createExportData() -> ExportData {
        return ExportData(
            exportDate: Date(),
            currentStreak: store.currentStreak,
            longestStreak: store.longestStreak,
            startDate: store.startDate,
            lastRelapseDate: store.lastRelapseDate,
            milestones: store.milestones,
            habits: loadHabitsFromStorage(),
            appVersion: "1.0.0"
        )
    }
    
    private func loadHabitsFromStorage() -> [Habit] {
        if let habitsData = UserDefaults.standard.data(forKey: "user_habits"),
           let habits = try? JSONDecoder().decode([Habit].self, from: habitsData) {
            return habits
        }
        return []
    }
    
    private func shareFile(_ fileURL: URL) {
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityViewController, animated: true)
        }
    }
}

struct CrisisResourcesView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: DS.Spacing.lg) {
                header
                
                emergencyContacts
                
                crisisHotlines
                
                localResources
            }
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.bottom, DS.Spacing.xl)
        }
        .background(DS.ColorToken.creamBG.ignoresSafeArea(.all))
        .navigationTitle("Crisis Resources")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var header: some View {
        VStack(spacing: DS.Spacing.md) {
            Image(systemName: "heart.fill")
                .font(.system(size: 50))
                .foregroundStyle(DS.ColorToken.purpleGradient)
            
            Text("You're Not Alone")
                .font(DS.FontToken.rounded(24, .bold))
                .foregroundStyle(DS.ColorToken.textPrimary)
            
            Text("If you're in crisis, reach out for help immediately")
                .font(DS.FontToken.rounded(16))
                .foregroundStyle(DS.ColorToken.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, DS.Spacing.lg)
    }
    
    private var emergencyContacts: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Emergency Contacts")
                .font(DS.FontToken.rounded(18, .semibold))
                .foregroundStyle(DS.ColorToken.textPrimary)
            
            LazyVStack(spacing: DS.Spacing.sm) {
                CrisisContactCard(
                    name: "National Suicide Prevention Lifeline",
                    number: "988",
                    description: "24/7 crisis support"
                )
                
                CrisisContactCard(
                    name: "SAMHSA National Helpline",
                    number: "1-800-662-4357",
                    description: "Substance abuse and mental health services"
                )
                
                CrisisContactCard(
                    name: "Crisis Text Line",
                    number: "Text HOME to 741741",
                    description: "24/7 crisis support via text"
                )
            }
        }
    }
    
    private var crisisHotlines: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Crisis Hotlines")
                .font(DS.FontToken.rounded(18, .semibold))
                .foregroundStyle(DS.ColorToken.textPrimary)
            
            SoftCard {
                VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                    Text("If you're having thoughts of self-harm or suicide:")
                        .font(DS.FontToken.rounded(16, .semibold))
                        .foregroundStyle(DS.ColorToken.textPrimary)
                    
                    Text("• Call 988 immediately")
                    Text("• Go to your nearest emergency room")
                    Text("• Tell someone you trust")
                    Text("• Remember: This feeling is temporary")
                    
                    Text("You are valued and your life matters.")
                        .font(DS.FontToken.rounded(14, .semibold))
                        .foregroundStyle(DS.ColorToken.purpleGradient)
                        .padding(.top, DS.Spacing.sm)
                }
            }
        }
    }
    
    private var localResources: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Local Resources")
                .font(DS.FontToken.rounded(18, .semibold))
                .foregroundStyle(DS.ColorToken.textPrimary)
            
            SoftCard {
                VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                    Text("Find local support:")
                        .font(DS.FontToken.rounded(16, .semibold))
                        .foregroundStyle(DS.ColorToken.textPrimary)
                    
                    Text("• AA/NA meetings")
                    Text("• Local treatment centers")
                    Text("• Mental health professionals")
                    Text("• Support groups")
                    Text("• Community resources")
                }
            }
        }
    }
}

struct CrisisContactCard: View {
    let name: String
    let number: String
    let description: String
    
    var body: some View {
        Button(action: {
            callCrisisNumber(number)
        }) {
            SoftCard {
                VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                    HStack {
                        Text(name)
                            .font(DS.FontToken.rounded(16, .semibold))
                            .foregroundStyle(DS.ColorToken.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "phone.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(DS.ColorToken.purpleGradient)
                    }
                    
                    Text(number)
                        .font(DS.FontToken.rounded(18, .bold))
                        .foregroundStyle(DS.ColorToken.purpleGradient)
                    
                    Text(description)
                        .font(DS.FontToken.rounded(14))
                        .foregroundStyle(DS.ColorToken.textSecondary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func callCrisisNumber(_ number: String) {
        let cleanNumber = number.replacingOccurrences(of: " ", with: "")
        let cleanNumber2 = cleanNumber.replacingOccurrences(of: "-", with: "")
        
        if let url = URL(string: "tel:\(cleanNumber2)") {
            UIApplication.shared.open(url)
        }
    }
}

struct RecoveryResourcesView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: DS.Spacing.lg) {
                header
                
                resourcesList
            }
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.bottom, DS.Spacing.xl)
        }
        .background(DS.ColorToken.creamBG.ignoresSafeArea(.all))
        .navigationTitle("Recovery Resources")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var header: some View {
        VStack(spacing: DS.Spacing.md) {
            Image(systemName: "book.fill")
                .font(.system(size: 50))
                .foregroundStyle(DS.ColorToken.purpleGradient)
            
            Text("Recovery Resources")
                .font(DS.FontToken.rounded(24, .bold))
                .foregroundStyle(DS.ColorToken.textPrimary)
            
            Text("Tools and resources to support your recovery journey")
                .font(DS.FontToken.rounded(16))
                .foregroundStyle(DS.ColorToken.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, DS.Spacing.lg)
    }
    
    private var resourcesList: some View {
        LazyVStack(spacing: DS.Spacing.sm) {
            ResourceCard(
                title: "12-Step Programs",
                description: "AA, NA, and other 12-step programs",
                icon: "person.3.fill"
            )
            
            ResourceCard(
                title: "Therapy & Counseling",
                description: "Professional mental health support",
                icon: "brain.head.profile"
            )
            
            ResourceCard(
                title: "Meditation & Mindfulness",
                description: "Mindfulness practices for recovery",
                icon: "leaf.fill"
            )
            
            ResourceCard(
                title: "Exercise & Wellness",
                description: "Physical health and wellness",
                icon: "figure.run"
            )
            
            ResourceCard(
                title: "Support Groups",
                description: "Peer support and community",
                icon: "person.2.fill"
            )
        }
    }
}

struct ResourceCard: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        SoftCard {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(DS.ColorToken.purpleGradient)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(DS.FontToken.rounded(16, .semibold))
                        .foregroundStyle(DS.ColorToken.textPrimary)
                    
                    Text(description)
                        .font(DS.FontToken.rounded(14))
                        .foregroundStyle(DS.ColorToken.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(DS.ColorToken.textSecondary)
            }
        }
    }
}

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                header
                
                content
            }
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.bottom, DS.Spacing.xl)
        }
        .background(DS.ColorToken.creamBG.ignoresSafeArea(.all))
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var header: some View {
        VStack(spacing: DS.Spacing.md) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 50))
                .foregroundStyle(DS.ColorToken.purpleGradient)
            
            Text("Privacy Policy")
                .font(DS.FontToken.rounded(24, .bold))
                .foregroundStyle(DS.ColorToken.textPrimary)
            
            Text("Last updated: \(DateFormatter.privacyDateFormatter.string(from: Date()))")
                .font(DS.FontToken.rounded(14))
                .foregroundStyle(DS.ColorToken.textSecondary)
        }
        .padding(.top, DS.Spacing.lg)
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            policySection(
                title: "Information We Collect",
                content: "We collect only the data you provide directly through the app, including your sobriety streak, habits, and milestone achievements. All data is stored locally on your device using iOS UserDefaults."
            )
            
            policySection(
                title: "How We Use Your Information",
                content: "Your data is used solely to provide you with sobriety tracking features, progress visualization, and motivational content. We do not share, sell, or transmit your personal data to third parties."
            )
            
            policySection(
                title: "Data Storage",
                content: "All your data is stored locally on your device. We do not maintain servers or cloud storage of your personal information. You can export your data at any time through the app's settings."
            )
            
            policySection(
                title: "Your Rights",
                content: "You have the right to access, modify, or delete your data at any time. You can reset all data through the app settings or contact us for assistance."
            )
            
            policySection(
                title: "Contact Us",
                content: "If you have any questions about this Privacy Policy, please contact us at privacy@sobrietyapp.com"
            )
        }
    }
    
    private func policySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text(title)
                .font(DS.FontToken.rounded(18, .semibold))
                .foregroundStyle(DS.ColorToken.textPrimary)
            
            Text(content)
                .font(DS.FontToken.rounded(16))
                .foregroundStyle(DS.ColorToken.textSecondary)
        }
    }
}

// MARK: - Terms of Service View
struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                header
                
                content
            }
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.bottom, DS.Spacing.xl)
        }
        .background(DS.ColorToken.creamBG.ignoresSafeArea(.all))
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var header: some View {
        VStack(spacing: DS.Spacing.md) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 50))
                .foregroundStyle(DS.ColorToken.purpleGradient)
            
            Text("Terms of Service")
                .font(DS.FontToken.rounded(24, .bold))
                .foregroundStyle(DS.ColorToken.textPrimary)
            
            Text("Last updated: \(DateFormatter.privacyDateFormatter.string(from: Date()))")
                .font(DS.FontToken.rounded(14))
                .foregroundStyle(DS.ColorToken.textSecondary)
        }
        .padding(.top, DS.Spacing.lg)
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            termsSection(
                title: "Acceptance of Terms",
                content: "By using the Sobriety App, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the app."
            )
            
            termsSection(
                title: "App Purpose",
                content: "This app is designed to support individuals in their sobriety journey. It is not a substitute for professional medical advice, treatment, or therapy."
            )
            
            termsSection(
                title: "User Responsibilities",
                content: "You are responsible for the accuracy of data you enter and for maintaining the security of your device. The app is for personal use only."
            )
            
            termsSection(
                title: "Limitation of Liability",
                content: "The app is provided 'as is' without warranties. We are not liable for any decisions made based on app data or any consequences of app usage."
            )
            
            termsSection(
                title: "Changes to Terms",
                content: "We may update these terms from time to time. Continued use of the app after changes constitutes acceptance of the new terms."
            )
            
            termsSection(
                title: "Contact Information",
                content: "For questions about these Terms of Service, please contact us at legal@sobrietyapp.com"
            )
        }
    }
    
    private func termsSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text(title)
                .font(DS.FontToken.rounded(18, .semibold))
                .foregroundStyle(DS.ColorToken.textPrimary)
            
            Text(content)
                .font(DS.FontToken.rounded(16))
                .foregroundStyle(DS.ColorToken.textSecondary)
        }
    }
}

// MARK: - DateFormatter Extension for Privacy/Terms
extension DateFormatter {
    static let privacyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
}
