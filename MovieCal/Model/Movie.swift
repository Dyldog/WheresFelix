//
//  Movie.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation
import GRDB

struct Movie: Hashable, Codable, FetchableRecord, PersistableRecord {
    let id: Int
    let imageURL: URL
    let title: String
    
    static let personMovie = hasMany(PersonMovie.self)
//    let releaseDate: String
//    let genreIDs: [Int]
//    
//    static let movieGenres = hasMany(MovieGenre.self)
//    static let genres = hasMany(Genre.self, through: movieGenres, using: MovieGenre.genre)
}
