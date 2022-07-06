//
//  ClusterManager.swift
//  MapClustering
//
//  Created by Alex on 5.07.22.
//

import Foundation
import MapKit

private struct Constants {
    static let defaultMapZoom: Double = 0.375

    static let latitudesRange = -9...9
    static let longitudesRange = -18...18

    static let degreeMultiplier: Double = 10

    static let clustersCount = 20

    static let zoomAdditions = 0.25

    static let singleAnnotation = 1

    static let mapRectOffsetDelta: Double = 5000
}

protocol AnnotationsManagable {
    func setAllAnnotations(_ annotations: Annotations)
    func setZoom(_ zoom: Double)
    func getAnnotations(for mapRect: MKMapRect) -> AnnotationsManager.GetAnnotationsCallback
    func cluster(annotations: Annotations, in areaRect: CGRect) -> AnnotationsManager.ClusterAnnotationsCallback
}

class AnnotationsManager {
    // MARK: - Types

    typealias GetAnnotationsCallback = (areaRect: CGRect, annotations: Annotations)
    typealias ClusterAnnotationsCallback = [CGPoint: Annotations]

    // MARK: - Private Properties

    private var collection: [CGPoint: Annotations] = [:]
    private var mapZoom = Constants.defaultMapZoom
}

// MARK: - AnnotationsManagable

extension AnnotationsManager: AnnotationsManagable {
    func setAllAnnotations(_ annotations: Annotations) {
        let latitudes = Constants.latitudesRange.map { Double($0) * Constants.degreeMultiplier }
        let longitudes = Constants.longitudesRange.map { Double($0) * Constants.degreeMultiplier }
        let rects = latitudes
            .flatMap { latitude in
                longitudes.map { longitude in
                    CGPoint(x: longitude, y: latitude)
                }
            }
        collection = rects.reduce([:]) { dict, value in
            var dict = dict
            dict[value] = []
            return dict
        }

        for element in annotations {
            let y = (element.coordinate.latitude / Constants.degreeMultiplier).rounded(.down)
            let x = (element.coordinate.longitude / Constants.degreeMultiplier).rounded(.down)
            let rect = CGPoint(x: x * Constants.degreeMultiplier, y: y * Constants.degreeMultiplier)
            if collection[rect] != nil {
                collection[rect]? += [element]
            } else {
                assertionFailure()
            }
        }
    }

    func setZoom(_ zoom: Double) {
        mapZoom = zoom
    }

    func getAnnotations(for mapRect: MKMapRect) -> AnnotationsManager.GetAnnotationsCallback {
        let mapRect = mapRect.offsetBy(dx: Constants.mapRectOffsetDelta, dy: Constants.mapRectOffsetDelta)
        let min = MKMapPoint(x: mapRect.minX, y: mapRect.minY).coordinate
        let max = MKMapPoint(x: mapRect.maxX, y: mapRect.maxY).coordinate
        
        let minimalLongitude = Double.minimum(min.longitude, max.longitude)
        let minimalLatitude = Double.minimum(min.latitude, max.latitude)
        
        let rangeX = abs(
            Int(max.longitude / Constants.degreeMultiplier) - Int(min.longitude / Constants.degreeMultiplier)
        )
        let rangeY = abs(
            Int(max.latitude / Constants.degreeMultiplier) - Int(min.latitude / Constants.degreeMultiplier)
        )

        let rect = CGRect(
            x: minimalLongitude,
            y: minimalLatitude,
            width: abs(min.longitude - max.longitude),
            height: abs(min.latitude - max.latitude)
        )

        let lowerRoundedX = (minimalLongitude / Constants.degreeMultiplier).rounded(.down) * Constants.degreeMultiplier
        let lowerRoundedY = (minimalLatitude / Constants.degreeMultiplier).rounded(.down) * Constants.degreeMultiplier
        
        let points: [CGPoint] = (.zero...rangeX).flatMap { x in
            (.zero...rangeY).map { y in
                return CGPoint(
                    x: (lowerRoundedX + Double(x) * Constants.degreeMultiplier).rounded(.down),
                    y: (lowerRoundedY + Double(y) * Constants.degreeMultiplier).rounded(.down)
                )
            }
        }
        
        var annotations = points
            .compactMap { collection[$0] }
            .filter { !$0.isEmpty }

        if
            annotations.first?.count != annotations.last?.count,
            annotations.first?.first?.coordinate != annotations.last?.first?.coordinate
        {
            annotations[annotations.firstIndex] = annotations[annotations.firstIndex]
                .filter { rect.contains(CGPoint(x: $0.coordinate.longitude, y: $0.coordinate.latitude)) }
            annotations[annotations.lastIndex] = annotations[annotations.lastIndex]
                .filter { rect.contains(CGPoint(x: $0.coordinate.longitude, y: $0.coordinate.latitude)) }
        } else if annotations.count == Constants.singleAnnotation {
            annotations[annotations.firstIndex] = annotations[annotations.firstIndex]
                .filter { rect.contains(CGPoint(x: $0.coordinate.longitude, y: $0.coordinate.latitude)) }
        } else {
            return (rect, [])
        }

        let flatAnnotations = annotations.flatMap { $0 }

        return (rect, flatAnnotations)
    }

    func cluster(annotations: Annotations, in areaRect: CGRect) -> AnnotationsManager.ClusterAnnotationsCallback {
        let minimalLongitude = areaRect.minX
        let minimalLatitude = areaRect.minY

        let maxClustersCount = Int((Double(Constants.clustersCount) * mapZoom + Constants.zoomAdditions).rounded())
        let clustersCount = annotations.count < maxClustersCount ? annotations.count : maxClustersCount
        let xIncrement = areaRect.width / Double(clustersCount)
        let yIncrement = areaRect.height / Double(clustersCount)

        var rawDictionory: [CGPoint: Annotations] = [:]
        for indexX in Int.zero..<clustersCount {
            let x = xIncrement * Double(indexX)
            for indexY in Int.zero..<clustersCount {
                let y = yIncrement * Double(indexY)
                rawDictionory[CGPoint(x: minimalLongitude + x, y: minimalLatitude + y)] = []
            }
        }

        for annotation in annotations {
            let x = ((annotation.coordinate.longitude - minimalLongitude) / xIncrement).rounded(.down)
            let y = ((annotation.coordinate.latitude - minimalLatitude) / yIncrement).rounded(.down)
            let rect = CGPoint(x: minimalLongitude + (xIncrement * x), y: minimalLatitude + (yIncrement * y))
            if rawDictionory[rect] == nil { continue }
            rawDictionory[rect]? += [annotation]
        }

        rawDictionory.keys.forEach {
            guard rawDictionory[$0]?.isEmpty == true else { return }
            rawDictionory[$0] = nil
        }

        let accurateDictionary = rawDictionory.values.reduce([CGPoint: Annotations]()) { dictionary, values in
            let count = Double(values.count)
            let latitude = values.map(\.coordinate.latitude).reduce(Double.zero, +) / count
            let longitude = values.map(\.coordinate.longitude).reduce(Double.zero, +) / count
            var dictionary = dictionary
            dictionary[CGPoint(x: longitude, y: latitude)] = values
            return dictionary
        }

        return accurateDictionary
    }
}

extension CGPoint: Hashable {
    public static func == (lhs: CGPoint, rhs: CGPoint) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}
