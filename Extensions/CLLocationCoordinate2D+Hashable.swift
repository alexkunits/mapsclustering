//
//  CLLocationCoordinate2D+Hashable.swift
//  MapClustering
//
//  Created by Alex on 5.07.22.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D: Hashable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(longitude)
        hasher.combine(latitude)
    }
}
