import SwiftUI

@main
struct WorkyisWidgetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .windowStyle(.plain)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}
