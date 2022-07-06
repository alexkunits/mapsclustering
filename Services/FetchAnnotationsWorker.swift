//
//  FetchAnnotationsLoader.swift
//  MapClustering
//
//  Created by Alex on 4.07.22.
//

import Foundation
import CoreLocation

private struct Constants {
    static let fileURL = Bundle.main.url(forResource: "annotations", withExtension: "csv")

    static let componentsCount = 4
    static let idComponentIndex = 1
    static let latitudeComponentIndex = 2
    static let longitudeComponentIndex = 3
}

protocol FetchAnnotationsWorkerProtocol {
    typealias FetchCompletion = (Result<Annotations, Error>) -> ()
    func fetch(useCache isUsingCache: Bool, completion: @escaping FetchCompletion)
}

extension FetchAnnotationsWorkerProtocol {
    func fetch(useCache isUsingCache: Bool, completion: @escaping FetchCompletion) {
        fetch(useCache: isUsingCache, completion: completion)
    }
}

struct FetchAnnotationsWorker {
    // MARK: - Private Properties

    private let annotations: Annotations

    // MARK: - Init

    init(annotations: Annotations = []) {
        self.annotations = annotations
    }
}

// MARK: - FetchAnnotationsWorkerProtocol

extension FetchAnnotationsWorker: FetchAnnotationsWorkerProtocol {
    func fetch(useCache isUsingCache: Bool, completion: @escaping FetchCompletion) {
        if isUsingCache, !annotations.isEmpty {
            completion(.success(annotations))
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let data: String
            do {
                guard let url = Constants.fileURL else { return }
                data = try String(contentsOf: url)
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(FetchError.sourceNotFound))
                }
                return
            }

            let annotations = data
                .components(separatedBy: "\n")
                .compactMap{ row -> Annotation? in
                    let components = row.components(separatedBy: ",")
                    guard
                        components.count >= Constants.componentsCount,
                        let id = Int(components[Constants.idComponentIndex]),
                        let latitude = Double(components[Constants.latitudeComponentIndex]),
                        let longitude = Double(components[Constants.longitudeComponentIndex])
                    else { return nil }
                    return Annotation(
                        id: id,
                        coordinate: CLLocationCoordinate2D(
                            latitude: latitude,
                            longitude: longitude
                        )
                    )
                }

            DispatchQueue.main.async {
                completion(.success(Array(annotations)))
            }
        }
    }
}
