import SwiftUI
import HomeKit

@main
struct HomeKit41App: App {
    @State private var timerFinished = false
    var body: some Scene {
        WindowGroup {
            MainView()
//            TimerView(timerFinished: $timerFinished)
        }
    }
}
