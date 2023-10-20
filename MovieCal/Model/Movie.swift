//
//  Movie.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation
import GRDB

struct Movie: Hashable, Codable {
    let id: Int
    let imageURL: URL
    let title: String
    let overview: String
    let genres: [Genre]
}
