//
//  Identifiable.swift
//  outland
//
//  Created by Manuel on 04/06/21.
//

import Foundation

/// Helper that returns the class name of an object
protocol Identifiable {
    var objectName: String { get }
    static var objectName: String { get }
}

extension Identifiable {
    public var objectName: String {
        return String(describing: type(of: self))
    }

    public static var objectName: String {
        return String(describing: self)
    }
}

extension NSObject: Identifiable {}
