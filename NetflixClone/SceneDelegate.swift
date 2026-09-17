//
//  SceneDelegate.swift
//  NetflixClone
//
//  Created by Ahmed Halilovic on 4. 12. 2023..
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        // The app is designed dark-first, matching the Netflix brand.
        window.overrideUserInterfaceStyle = .dark
        window.rootViewController = MainTabBarViewController()
        window.makeKeyAndVisible()
        self.window = window
    }
}
