//
//  MapViewAnnotation.swift
//  MapClustering
//
//  Created by Alex on 5.07.22.
//

import Foundation
import MapKit

final class MapViewAnnotation: NSObject, MKAnnotation {
    var id: Int
    var coordinate: CLLocationCoordinate2D

    init(annotation: Annotation) {
        self.id = annotation.id
        self.coordinate = annotation.coordinate
        super.init()
    }
}
