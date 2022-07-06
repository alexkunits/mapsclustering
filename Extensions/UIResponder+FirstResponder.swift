//
//  UIResponder+FirstResponder.swift
//  MapClustering
//
//  Created by Alex on 6.07.22.
//

import UIKit

public extension UIResponder {
    func firstResponder<Responder>(of type: Responder.Type) -> Responder? {
        if let responder = self as? Responder {
            return responder
        } else {
            guard let next = next else { return nil }
            return next.firstResponder(of: type)
        }
    }
}
