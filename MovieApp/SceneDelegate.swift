//
//  SceneDelegate.swift
//  MovieApp
//
//  Created by Kenya Gordon on 9/28/20.
//  Copyright © 2020 Kenya Gordon. All rights reserved.
//

import Foundation
import UIKit


final class SceneDelegate : UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        let viewController = MainMenuViewController()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
}

