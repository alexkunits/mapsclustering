//
//  MapScreenView.swift
//  MapClustering
//
//  Created by Alex on 5.07.22.
//

import Foundation
import UIKit
import MapKit

private struct Constants {
    static let singleAnnotationImageName = "wifi_logo"
    static let singleAnnotationText = "Wi-Fi"

    static let clusterAnnotationImageName = "wifi_hub"

    static let labelMinimumScaleFactor = 0.1

    static let commonConstraintMultiplier: CGFloat = 1
    static let commonConstraintConstant: CGFloat = 0
    static let loaderViewSizeConstraintConstant: CGFloat = 60
    static let loaderViewTopConstraintConstant: CGFloat = 16

    static let loaderViewImagePath = "frame-"
    static let loaderViewFramerate = 60
}

final class MapScreenView: UIView {
    // MARK: - Subview Properties

    private let loaderView = LoaderImageView(
        imagePath: Constants.loaderViewImagePath,
        framerate: Constants.loaderViewFramerate
    )
    
    private let mapView = MKMapView()
    private let mapViewDirector: MapViewDirectable = MapViewDirector()

    // MARK: - Init

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    private func commonInit() {
        addSubviews()
        makeConstraints()

        configureMap()
    }
    
    private func configureMap() {
        mapViewDirector.subscribeForNotificaitons(from: mapView)
    }

    private func addSubviews() {
        addSubview(mapView)
        addSubview(loaderView)
    }

    private func makeConstraints() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        loaderView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [
                NSLayoutConstraint(
                    item: mapView,
                    attribute: .top,
                    relatedBy: .equal,
                    toItem: self,
                    attribute: .top,
                    multiplier: Constants.commonConstraintMultiplier,
                    constant: Constants.commonConstraintConstant
                ),
                NSLayoutConstraint(
                    item: mapView,
                    attribute: .bottom,
                    relatedBy: .equal,
                    toItem: self,
                    attribute: .bottom,
                    multiplier: Constants.commonConstraintMultiplier,
                    constant: Constants.commonConstraintConstant
                ),
                NSLayoutConstraint(
                    item: mapView,
                    attribute: .leading,
                    relatedBy: .equal,
                    toItem: self,
                    attribute: .leading,
                    multiplier: Constants.commonConstraintMultiplier,
                    constant: Constants.commonConstraintConstant
                ),
                NSLayoutConstraint(
                    item: mapView,
                    attribute: .trailing,
                    relatedBy: .equal,
                    toItem: self,
                    attribute: .trailing,
                    multiplier: Constants.commonConstraintMultiplier,
                    constant: Constants.commonConstraintConstant
                )
            ]
        )

        NSLayoutConstraint.activate(
            [
                NSLayoutConstraint(
                    item: loaderView,
                    attribute: .centerX,
                    relatedBy: .equal,
                    toItem: self,
                    attribute: .centerX,
                    multiplier: Constants.commonConstraintMultiplier,
                    constant: Constants.commonConstraintConstant
                ),
                NSLayoutConstraint(
                    item: loaderView,
                    attribute: .top,
                    relatedBy: .equal,
                    toItem: self.safeAreaLayoutGuide,
                    attribute: .top,
                    multiplier: Constants.commonConstraintMultiplier,
                    constant: Constants.loaderViewTopConstraintConstant
                ),
                NSLayoutConstraint(
                    item: loaderView,
                    attribute: .height,
                    relatedBy: .equal,
                    toItem: nil,
                    attribute: .height,
                    multiplier: Constants.commonConstraintMultiplier,
                    constant: Constants.loaderViewSizeConstraintConstant
                ),
                NSLayoutConstraint(
                    item: loaderView,
                    attribute: .width,
                    relatedBy: .equal,
                    toItem: nil,
                    attribute: .width,
                    multiplier: Constants.commonConstraintMultiplier,
                    constant: Constants.loaderViewSizeConstraintConstant
                ),
                
            ]
        )
    }
}

// MARK: - Configurable

extension MapScreenView: Configurable {
    enum ViewModel {
        case content(annotations: [MKAnnotation])
        case loading
        case instantiateNextState
    }

    func configure(with viewModel: ViewModel) {
        switch viewModel {
        case .content(annotations: let annotations):
            loaderView.stopAnimating()
            mapViewDirector.addAnnotations(annotations)
        case .loading:
            loaderView.startAnimating()
        case .instantiateNextState:
            mapViewDirector.forceReloadAnnotations()
        }
    }
}
