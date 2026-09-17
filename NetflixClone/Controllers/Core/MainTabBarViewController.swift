//
//  MainTabBarViewController.swift
//  NetflixClone
//
//  Created by Ahmed Halilovic on 4. 12. 2023..
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // The modern UITab API — on iOS 26 the tab bar renders as floating Liquid Glass,
        // and UISearchTab morphs into the dedicated search field.
        tabs = [
            UITab(title: "Home",
                  image: UIImage(systemName: "house"),
                  identifier: "tab.home") { _ in
                UINavigationController(rootViewController: HomeViewController())
            },
            UITab(title: "New & Hot",
                  image: UIImage(systemName: "play.rectangle.on.rectangle"),
                  identifier: "tab.upcoming") { _ in
                UINavigationController(rootViewController: UpcomingViewController())
            },
            UITab(title: "Downloads",
                  image: UIImage(systemName: "arrow.down.circle"),
                  identifier: "tab.downloads") { _ in
                UINavigationController(rootViewController: DownloadsViewController())
            },
            UISearchTab { _ in
                UINavigationController(rootViewController: SearchViewController())
            }
        ]

        tabBar.tintColor = .label

        #if DEBUG
        // Screenshot/UI-test hook: launch with `-selectedTabIndex <n>` to open a specific tab.
        let requestedTab = UserDefaults.standard.integer(forKey: "selectedTabIndex")
        if requestedTab > 0 && requestedTab < tabs.count {
            selectedIndex = requestedTab
        }
        #endif
    }
}
