//
//  String+Empty.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation

extension String {
    static var empty: String { "" }
}

extension Optional where Wrapped == String {
    var orEmpty: String { self ?? .empty }
}
