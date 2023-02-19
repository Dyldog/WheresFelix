//
//  TMDBMovie.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation


struct TMDBMovie: Hashable, Codable {
    let id: Int
    let imageURL: URL
    let title: String
    let overview: String
    let releaseDate: String
    let genreIDs: [Int]
}
