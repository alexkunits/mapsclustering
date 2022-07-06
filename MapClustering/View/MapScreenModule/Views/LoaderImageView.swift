//
//  LoaderImageView.swift
//  MapClustering
//
//  Created by Alex on 6.07.22.
//

import Foundation
import UIKit

private struct Constants {
    static let animationDuration: TimeInterval = 1
}

final class LoaderImageView: UIImageView {
    // MARK: - Init

    init(imagePath: String, framerate: Int) {
        super.init(frame: .zero)
        animationImages = (.zero...framerate).compactMap { UIImage(named: imagePath + "\($0)") }
        animationDuration = Constants.animationDuration
        animationRepeatCount = Int.max
        startAnimating()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
