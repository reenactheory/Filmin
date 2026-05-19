import SwiftUI
import UIKit

@main
struct FilminApp: App {
    init() {
        // Unselected tab icon/title color: #A1A1AA
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color(hex: "#A1A1AA"))
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
    }
}
