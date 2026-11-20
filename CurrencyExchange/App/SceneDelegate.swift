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
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
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

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}
