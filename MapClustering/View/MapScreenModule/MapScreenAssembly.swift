//
//  MapScreenAssembly.swift
//  MapClustering
//
//  Created by Alex on 5.07.22.
//

import Foundation
import UIKit

final class MapScreenAssembly {
    func assemble() -> UIViewController {
        let presenter = MapScreenPresenter()
        let interactor = MapScreenInteractor(
            presenter: presenter,
            fetchWorker: FetchAnnotationsWorker(),
            annotationsWorker: ManageAnnotationsWorker(clusterManager: AnnotationsManager())
        )
        let viewController = MapScreenViewController(interactor: interactor)
        presenter.viewController = viewController
        return viewController
    }
}
