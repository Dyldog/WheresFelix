//
//  MovieGenre.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation

struct MovieGenre: Decodable, Hashable, Identifiable {
    let id: Int
    let name: String
}
