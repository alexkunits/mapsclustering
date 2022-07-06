//
//  MapScreenPresenter.swift
//  MapClustering
//
//  Created by Alex on 5.07.22.
//

import Foundation
import MapKit

private struct Constants {
    static let annotationsCountOne = 1
}

protocol MapScreenPresentationLogic {
    func present(response: MapScreenDataFlow.InitialState.Response)
    func present(response: MapScreenDataFlow.MapUpdate.Response)
}

final class MapScreenPresenter {
    // MARK: - Public Properties

    weak var viewController: MapScreenDisplayLogic?

    // MARK: - Init

    init() {}
}

// MARK: - MapScreenPresentationLogic

extension MapScreenPresenter: MapScreenPresentationLogic {
    func present(response: MapScreenDataFlow.InitialState.Response) {
        viewController?.display(viewModel: MapScreenView.ViewModel.instantiateNextState)
    }

    func present(response: MapScreenDataFlow.MapUpdate.Response) {
        let annotations: [MKAnnotation] = response.annotations.keys.compactMap { key in
            guard let annotations = response.annotations[key] else { return nil }
            switch annotations.count {
            case .zero:
                assertionFailure()
                return nil
            case Constants.annotationsCountOne:
                guard let annotation = annotations.first else { return nil }
                return MapViewAnnotation(annotation: annotation)
            default:
                return MapViewClusterAnnotation(point: key, annotations: annotations)
            }
        }

        viewController?.display(viewModel: MapScreenView.ViewModel.content(annotations: annotations))
    }
}
