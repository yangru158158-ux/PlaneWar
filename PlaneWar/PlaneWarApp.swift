import SwiftUI

@main
struct PlaneWarApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
                .statusBarHidden(true)
                .persistentSystemOverlays(.hidden)
                .preferredColorScheme(.dark)
                .ignoresSafeArea()
        }
    }
}
