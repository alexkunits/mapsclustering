//
//  AnnotationView.swift
//  MapClustering
//
//  Created by Alex on 4.07.22.
//

import Foundation
import UIKit
import MapKit

private struct Constants {
    static let singleAnnotationImageName = "wifi_logo"
    static let singleAnnotationText = "Wi-Fi"

    static let bigClusterAnnotationImageName = "wifi_hub_big"
    static let mediumClusterAnnotationImageName = "wifi_hub_medium"
    static let smallClusterAnnotationImageName = "wifi_hub_small"

    static let labelMinimumScaleFactor = 0.1

    static let commonConstraintMultiplier: CGFloat = 1
    static let commonConstraintConstant: CGFloat = 0
    static let imageViewConstraintConstant: CGFloat = 30

    static let smallClusterCount = 20
    static let mediumClusterCount = 500
}

final class AnnotationView: MKAnnotationView {
    // MARK: - Public Properties

    override var reuseIdentifier: String? { String(describing: Self.self) }

    // MARK: - Subview Properties

    private let imageView = UIImageView()
    private let stackView = UIStackView()
    private let label = UILabel()


    // MARK: - Init

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - MKAnnotationView

    override func prepareForDisplay() {
        super.prepareForDisplay()

        if let cluster = annotation as? MapViewClusterAnnotation {
            label.text = "\(cluster.annotations.count)"
            let imageName: String
            switch cluster.annotations.count {
            case 0...Constants.smallClusterCount:
                imageName = Constants.smallClusterAnnotationImageName
            case Constants.smallClusterCount...Constants.mediumClusterCount:
                imageName = Constants.mediumClusterAnnotationImageName
            default:
                imageName = Constants.bigClusterAnnotationImageName
            }
            imageView.image = UIImage(named: imageName)
        } else {
            label.text = Constants.singleAnnotationText
            imageView.image = UIImage(named: Constants.singleAnnotationImageName)
        }
    }

    // MARK: - Private Methods

    private func commonInit() {
        stackView.axis = .vertical
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = Constants.labelMinimumScaleFactor
        imageView.contentMode = .center

        addSubviews()
        makeConstraints()
    }

    private func addSubviews() {
        addSubview(stackView)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
    }

    private func makeConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        NSLayoutConstraint.activate(
            [
                NSLayoutConstraint(
                    item: stackView,
                    attribute: .centerX,
                    relatedBy: .equal,
                    toItem: self,
                    attribute: .centerX,
                    multiplier: Constants.commonConstraintMultiplier,
                    constant: Constants.commonConstraintConstant
                ),
                NSLayoutConstraint(
                    item: stackView,
                    attribute: .centerY,
                    relatedBy: .equal,
                    toItem: self,
                    attribute: .centerY,
                    multiplier: Constants.commonConstraintMultiplier,
                    constant: Constants.commonConstraintConstant
                )
            ]
        )

        NSLayoutConstraint.activate(
            [
                NSLayoutConstraint(
                    item: imageView,
                    attribute: .width,
                    relatedBy: .equal,
                    toItem: imageView,
                    attribute: .height,
                    multiplier: Constants.commonConstraintMultiplier,
                    constant: Constants.commonConstraintConstant
                ),
                NSLayoutConstraint(
                    item: imageView,
                    attribute: .width,
                    relatedBy: .equal,
                    toItem: nil,
                    attribute: .width,
                    multiplier: Constants.commonConstraintMultiplier,
                    constant: Constants.imageViewConstraintConstant
                )
            ]
        )
    }
}
