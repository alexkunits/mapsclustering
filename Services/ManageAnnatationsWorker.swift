//
//  ClusterManagerWorker.swift
//  MapClustering
//
//  Created by Alex on 5.07.22.
//

import Foundation
import MapKit

private struct Constants {
    static let operationQueueName = "Alex.annotations.clustering"
    static let maxConcurrentOperationCount = 1
    static let delay = 1
}

protocol ManageAnnotationsWorkerProtocol {
    func setAllAnnotations(_ annotations: Annotations)
    func setZoom(_ zoom: Double)
    func getAnnotations(for mapRect: MKMapRect, completion: @escaping ([CGPoint: Annotations]) -> ())
}

final class ManageAnnotationsWorker {
    private let clusterManager: AnnotationsManagable

    private lazy var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.name = Constants.operationQueueName
        operationQueue.maxConcurrentOperationCount = Constants.maxConcurrentOperationCount
        return operationQueue
    }()

    private var workItem: DispatchWorkItem?

    init(clusterManager: AnnotationsManagable) {
        self.clusterManager = clusterManager
    }

    private func delayOperation(for seconds: Int,_ operation: Operation) {
        workItem?.cancel()
        let workItem = DispatchWorkItem { [weak self, operation] in
            guard self?.workItem?.isCancelled == false else { return }
            self?.operationQueue.addOperation(operation)
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(seconds), execute: workItem)
        self.workItem = workItem
    }
}

extension ManageAnnotationsWorker: ManageAnnotationsWorkerProtocol {
    func setAllAnnotations(_ annotations: Annotations) {
        clusterManager.setAllAnnotations(annotations)
    }

    func setZoom(_ zoom: Double) {
        clusterManager.setZoom(zoom)
    }

    func getAnnotations(for mapRect: MKMapRect, completion: @escaping ([CGPoint: Annotations]) -> ()) {
        let operation = AnnotationsOperation(mapRect: mapRect, clusterManager: clusterManager) { [completion] result in
            DispatchQueue.main.async { completion(result) }
        }
        operationQueue.cancelAllOperations()
        delayOperation(for: Constants.delay, operation)
    }
}
