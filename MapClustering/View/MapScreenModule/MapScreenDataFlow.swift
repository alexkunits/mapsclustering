//
//  MapScreenDataFlow.swift
//  MapClustering
//
//  Created by Alex on 5.07.22.
//

import Foundation
import MapKit


public enum MapScreenDataFlow {
    struct InitialState {
        struct Request {
            
        }

        struct Response {
            
        }
    }

    struct MapUpdate {
        struct Request {
            let mapRect: MKMapRect
            let mapZoom: Double
        }

        struct Response {
            let annotations: [CGPoint: Annotations]
        }
    }
}
