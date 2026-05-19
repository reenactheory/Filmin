import SwiftUI
import UIKit

@main
struct FilminApp: App {
    init() {
        // Unselected tab icon/title color: #A1A1AA
        let unselected = UIColor(Color(hex: "#A1A1AA"))
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()

        let attrs: [NSAttributedString.Key: Any] = [.foregroundColor: unselected]
        for itemAppearance in [
            appearance.stackedLayoutAppearance,
            appearance.inlineLayoutAppearance,
            appearance.compactInlineLayoutAppearance
        ] {
            itemAppearance.normal.iconColor = unselected
            itemAppearance.normal.titleTextAttributes = attrs
        }

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().unselectedItemTintColor = unselected
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
    }
}
