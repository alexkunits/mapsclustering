//
//  MapScreenViewController.swift
//  MapClustering
//
//  Created by Alex on 5.07.22.
//

import Foundation
import UIKit
import MapKit

protocol MapScreenDisplayLogic: AnyObject {
    func display(viewModel: MapScreenView.ViewModel)
}

final class MapScreenViewController: UIViewController {
    // MARK: - Private Properties

    private let interactor: MapScreenBusinesLogic

    // MARK: - Subview Properties

    private let rootView = MapScreenView()

    // MARK: - UIViewController

    init(interactor: MapScreenBusinesLogic) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        interactor.obtain(request: MapScreenDataFlow.InitialState.Request())
    }
}

// MARK: - MapScreenDisplayLogic

extension MapScreenViewController: MapScreenDisplayLogic {
    func display(viewModel: MapScreenView.ViewModel) {
        rootView.configure(with: viewModel)
    }
}

// MARK: - MapViewDirectableOutput

extension MapScreenViewController: MapViewDirectableOutput {
    func mapViewDidFinishUpdating(mapRect: MKMapRect, mapZoom: Double) {
        rootView.configure(with: .loading)
        interactor.obtain(request: MapScreenDataFlow.MapUpdate.Request(mapRect: mapRect, mapZoom: mapZoom))
    }
}
