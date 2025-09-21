import SwiftUI
import FirebaseCore


@main
struct HelloWorld_ToDoListApp: App {
    init() {
        FirebaseConfiguration.shared.setLoggerLevel(.debug)
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
