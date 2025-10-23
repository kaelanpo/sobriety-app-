import SwiftUI

struct ContentView: View {
    @StateObject private var sobrietyStore = SobrietyStore()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SobrietyDashboard(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            HabitTrackingView()
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
                .tag(1)
            
            GamificationView()
                .tabItem {
                    Label("Analysis", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle.fill")
                }
                .tag(3)
        }
        .environmentObject(sobrietyStore)
        .tint(DS.ColorToken.tint)
    }
}

#Preview {
    ContentView()
}
