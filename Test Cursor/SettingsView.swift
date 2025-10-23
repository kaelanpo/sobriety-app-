import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: SobrietyStore
    @State private var showingRelapseConfirmation = false
    @State private var showingResetConfirmation = false
    
    var body: some View {
        NavigationView {
            List {
                profileSection
                dataSection
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
                    .foregroundStyle(DS.ColorToken.tint)
                
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
                // Handle contact support
            }
        }
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
            
            Button("Privacy Policy") {
                // Handle privacy policy
            }
            
            Button("Terms of Service") {
                // Handle terms of service
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
}

struct ExportDataView: View {
    @EnvironmentObject var store: SobrietyStore
    
    var body: some View {
        VStack(spacing: DS.Spacing.lg) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 60))
                .foregroundStyle(DS.ColorToken.tint)
            
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
        // Implementation for data export
        print("Exporting data...")
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
                .foregroundStyle(DS.ColorToken.tint)
            
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
                        .foregroundStyle(DS.ColorToken.tint)
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
        SoftCard {
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                Text(name)
                    .font(DS.FontToken.rounded(16, .semibold))
                    .foregroundStyle(DS.ColorToken.textPrimary)
                
                Text(number)
                    .font(DS.FontToken.rounded(18, .bold))
                    .foregroundStyle(DS.ColorToken.tint)
                
                Text(description)
                    .font(DS.FontToken.rounded(14))
                    .foregroundStyle(DS.ColorToken.textSecondary)
            }
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
                .foregroundStyle(DS.ColorToken.tint)
            
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
                    .foregroundStyle(DS.ColorToken.tint)
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
