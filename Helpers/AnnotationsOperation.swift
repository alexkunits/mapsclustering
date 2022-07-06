//
//  AnnotationsOperation.swift
//  MapClustering
//
//  Created by Alex on 5.07.22.
//

import Foundation
import MapKit

final class AnnotationsOperation: Operation {
    // MARK: - Private Properties

    private let mapRect: MKMapRect
    private let clusterManager: AnnotationsManagable
    private let completion: ([CGPoint: Annotations]) -> ()

    // MARK: - Init

    init(
        mapRect: MKMapRect,
        clusterManager: AnnotationsManagable,
        completion: @escaping ([CGPoint: Annotations]) -> ()
    ) {
        self.mapRect = mapRect
        self.clusterManager = clusterManager
        self.completion = completion
        super.init()
    }

    // MARK: - Operation

    override func main() {
        guard !isCancelled else { completion([:]) ; return }
        let getAnnotationsCallback = clusterManager.getAnnotations(for: mapRect)

        guard !isCancelled else { completion([:]) ; return }
        let clusteringCallback = clusterManager.cluster(
            annotations: getAnnotationsCallback.annotations,
            in: getAnnotationsCallback.areaRect
        )

        guard !isCancelled else { completion([:]) ; return }
        completion(clusteringCallback)
    }
}
