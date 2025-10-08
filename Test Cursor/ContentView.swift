import SwiftUI

struct ContentView: View {
    @StateObject private var sobrietyStore = SobrietyStore()
    
    var body: some View {
        TabView {
            SobrietyDashboard()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            MoodTrackingView()
                .tabItem {
                    Label("Mood", systemImage: "heart.fill")
                }
            
            HabitTrackingView()
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
            
            GamificationView()
                .tabItem {
                    Label("Analysis", systemImage: "chart.bar.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle.fill")
                }
        }
        .environmentObject(sobrietyStore)
        .tint(DS.ColorToken.tint)
    }
}

#Preview {
    ContentView()
}
