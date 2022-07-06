//
//  MKMapView+Zoom.swift
//  MapClustering
//
//  Created by Alex on 6.07.22.
//

import Foundation
import MapKit

private struct Constants {
    static let maxZoom: Double = 24
}

extension MKMapView {
    var mapZoom: Double {
        let zoomScale = visibleMapRect.size.width / Double(frame.size.width)
        let zoomExponent = log2(zoomScale)
        return (Constants.maxZoom - ceil(zoomExponent)) / Constants.maxZoom
    }
}
