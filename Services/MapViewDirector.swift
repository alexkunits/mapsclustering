//
//  ClusterManager.swift
//  MapClustering
//
//  Created by Alex on 4.07.22.
//

import Foundation
import MapKit

protocol MapViewDirectable {
    func subscribeForNotificaitons(from mapView: MKMapView)
    func forceReloadAnnotations()
    func addAnnotations(_ annotations: [MKAnnotation])
}

protocol MapViewDirectableOutput: AnyObject {
    func mapViewDidFinishUpdating(mapRect: MKMapRect, mapZoom: Double)
}

final class MapViewDirector: NSObject {
    // MARK: - Private Properties

    private weak var mapView: MKMapView?
}

// MARK: - MapViewDirectable

extension MapViewDirector: MapViewDirectable {
    func subscribeForNotificaitons(from mapView: MKMapView) {
        mapView.delegate = self
        mapView.register(
            AnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
        mapView.register(
            AnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier
        )
        self.mapView = mapView
    }

    func forceReloadAnnotations() {
        guard let mapView = mapView else { return }
        let responser = mapView.firstResponder(of: MapViewDirectableOutput.self)
        responser?.mapViewDidFinishUpdating(mapRect: mapView.visibleMapRect, mapZoom: mapView.mapZoom)
    }

    func addAnnotations(_ annotations: [MKAnnotation]) {
        mapView?.removeAnnotations(mapView?.annotations ?? [])
        mapView?.addAnnotations(annotations)
    }
}

// MARK: - MKMapViewDelegate

extension MapViewDirector: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = annotation is MapViewClusterAnnotation
            ? MKMapViewDefaultAnnotationViewReuseIdentifier
            : MKMapViewDefaultClusterAnnotationViewReuseIdentifier
        return mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated: Bool) {
        let responser = mapView.firstResponder(of: MapViewDirectableOutput.self)
        responser?.mapViewDidFinishUpdating(mapRect: mapView.visibleMapRect, mapZoom: mapView.mapZoom)
    }
}
