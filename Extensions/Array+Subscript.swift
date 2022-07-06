//
//  Array+Subscript.swift
//  MapClustering
//
//  Created by Alex on 5.07.22.
//

import Foundation

private struct Constants {
    static let divider = 1
}

extension Array {
    var firstIndex: Int { .zero }

    var lastIndex: Int { count - Constants.divider }
}
