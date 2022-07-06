//
//  Configurable.swift
//  MapClustering
//
//  Created by Alex on 5.07.22.
//

import Foundation

public protocol UnsafeConfigurable {
    func _configure(with viewModel: Any)
}

public protocol Configurable: UnsafeConfigurable {
    associatedtype ViewModel
    func configure(with viewModel: ViewModel)
}

public extension Configurable {
    func _configure(with viewModel: Any) {
        if let concreteViewModel = viewModel as? ViewModel {
            configure(with: concreteViewModel)
        } else {
            assertionFailure(
                """
                    Invalid ViewModel type,
                    expect \(String(reflecting: ViewModel.self))
                    got: \(String(reflecting: viewModel.self))
                """
            )
        }
    }
}
