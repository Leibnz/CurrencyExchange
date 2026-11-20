//
//  SceneDelegate.swift
//  CurrencyExchange
//
//  Created by Andrew on 14.10.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // MARK: - Dependencies

        let networkClient = URLSessionNetworkClient()
        let repository = DefaultExchangeRatesRepository(networkClient: networkClient, configuration: .production)
        let viewModel = ExchangeViewModel(
            repository: repository
        )

        let viewController = ExchangeViewController(viewModel: viewModel)

        // MARK: - Window

        let window = UIWindow(windowScene: windowScene)

        window.rootViewController = viewController
        window.makeKeyAndVisible()

        self.window = window
    }

    func sceneDidDisconnect(_: UIScene) {}

    func sceneDidBecomeActive(_: UIScene) {}

    func sceneWillResignActive(_: UIScene) {}

    func sceneWillEnterForeground(_: UIScene) {}

    func sceneDidEnterBackground(_: UIScene) {}
}
