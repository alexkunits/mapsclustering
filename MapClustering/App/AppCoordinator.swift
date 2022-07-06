//
//  AppCoordinator.swift
//  MapClustering
//
//  Created by Alex on 6.07.22.
//

import Foundation
import UIKit

final class AppCoordinator {
    func startFlow(with window: UIWindow?) {
        let module = makeMapScreen()

        window?.rootViewController = module
    }
}

extension AppCoordinator {
    private func makeMapScreen() -> UIViewController {
        let assembly = MapScreenAssembly()
        return assembly.assemble()
    }
}
