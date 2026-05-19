import SwiftUI
import UIKit

@main
struct FilminApp: App {
    init() {
        // Selected: black, Unselected: #A1A1AA — applied to icon AND title
        // across all three tab bar layouts.
        let unselected = UIColor(Color(hex: "#A1A1AA"))
        let selected = UIColor.label

        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()

        let unselectedAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: unselected]
        let selectedAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: selected]

        for itemAppearance in [
            appearance.stackedLayoutAppearance,
            appearance.inlineLayoutAppearance,
            appearance.compactInlineLayoutAppearance
        ] {
            itemAppearance.normal.iconColor = unselected
            itemAppearance.normal.titleTextAttributes = unselectedAttrs
            itemAppearance.selected.iconColor = selected
            itemAppearance.selected.titleTextAttributes = selectedAttrs
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
