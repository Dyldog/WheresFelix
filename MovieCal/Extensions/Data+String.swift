//
//  Data+String.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation

extension Data {
    var string: String? {
        String(data: self, encoding: .utf8)
    }
}
