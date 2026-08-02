import SwiftUI

@main
struct music_iq_claude: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem { Label("Home", systemImage: "house.fill") }
                AboutView()
                    .tabItem { Label("About", systemImage: "info.circle.fill") }
                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape.fill") }
            }
        }
    }
}
