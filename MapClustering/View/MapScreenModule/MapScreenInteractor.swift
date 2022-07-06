//
//  MapScreenInteractor.swift
//  MapClustering
//
//  Created by Alex on 5.07.22.
//

import Foundation

protocol MapScreenBusinesLogic {
    func obtain(request: MapScreenDataFlow.InitialState.Request)
    func obtain(request: MapScreenDataFlow.MapUpdate.Request)
}


final class MapScreenInteractor {
    // MARK: - Private Properties

    private let presenter: MapScreenPresentationLogic

    private let fetchWorker: FetchAnnotationsWorkerProtocol
    private let annotationsWorker: ManageAnnotationsWorkerProtocol

    private var isAnnotationsWorkerReady = false

    // MARK: - Init

    init(
        presenter: MapScreenPresentationLogic,
        fetchWorker: FetchAnnotationsWorkerProtocol,
        annotationsWorker: ManageAnnotationsWorkerProtocol
    ) {
        self.presenter = presenter
        self.fetchWorker = fetchWorker
        self.annotationsWorker = annotationsWorker
    }

    // MARK: - Private Methods
}

// MARK: - MapScreenBusinesLogic

extension MapScreenInteractor: MapScreenBusinesLogic {
    func obtain(request: MapScreenDataFlow.InitialState.Request) {
        isAnnotationsWorkerReady = false
        fetchWorker.fetch(useCache: true) { [weak self] result in
            self?.isAnnotationsWorkerReady = true

            guard let self = self else { return }
            switch result {
            case let .success(annotations):
                self.annotationsWorker.setAllAnnotations(annotations)
                self.presenter.present(response: MapScreenDataFlow.InitialState.Response())
            case let .failure(error):
                assertionFailure(error.localizedDescription)
                break
            }
        }
    }

    func obtain(request: MapScreenDataFlow.MapUpdate.Request) {
        guard isAnnotationsWorkerReady else { return }
        annotationsWorker.setZoom(request.mapZoom)
        annotationsWorker.getAnnotations(for: request.mapRect) { [weak self] response in
            self?.presenter.present(
                response: MapScreenDataFlow.MapUpdate.Response(annotations: response)
            )
        }
    }
}
