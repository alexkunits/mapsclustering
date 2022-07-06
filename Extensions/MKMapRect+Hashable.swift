//
//  MKMapView+Hashable.swift
//  MapClustering
//
//  Created by Alex on 5.07.22.
//

import Foundation
import MapKit

extension MKMapRect: Hashable {
    public static func == (lhs: MKMapRect, rhs: MKMapRect) -> Bool {
        lhs.origin.coordinate == rhs.origin.coordinate
            && lhs.size.height == rhs.size.height
            && lhs.size.width == rhs.size.width
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(origin.coordinate)
        hasher.combine(size.height)
        hasher.combine(size.width)
    }
}
