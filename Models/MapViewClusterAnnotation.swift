//
//  MapViewClusterAnnotation.swift
//  MapClustering
//
//  Created by Alex on 5.07.22.
//

import Foundation
import MapKit

final class MapViewClusterAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var annotations: Annotations

    init(point: CGPoint, annotations: Annotations) {
        self.annotations = annotations
        self.coordinate = CLLocationCoordinate2D(latitude: point.y, longitude: point.x)
        super.init()
    }
}
