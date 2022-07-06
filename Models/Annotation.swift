//
//  Annotation.swift
//  MapClustering
//
//  Created by Alex on 4.07.22.
//

import Foundation
import CoreLocation

typealias Annotations = [Annotation]

struct Annotation {
    let id: Int
    let coordinate: CLLocationCoordinate2D
}
