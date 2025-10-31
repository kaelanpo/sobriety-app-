import SwiftUI
import SwiftData

@main
struct Test_CursorApp: App {
    var body: some Scene {
        WindowGroup {
            if #available(iOS 17.0, *) {
                ContentView()
                    .modelContainer(for: [CheckIn.self, Goal.self])
            } else {
                ContentView()
            }
        }
    }
}
