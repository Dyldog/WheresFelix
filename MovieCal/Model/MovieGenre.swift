//
//  MovieGenre.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation
import GRDB

struct MovieGenre: Codable, FetchableRecord, PersistableRecord {
    let movieId: Int
    let genreId: Int
//    static let 
//    let genre: Genre
}
