//
//  PersonMovie.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation
import GRDB

struct PersonMovie: Codable, FetchableRecord, PersistableRecord {
    let personId: Int64
    let movieId: Int64
    
    static let person = belongsTo(Person.self)
    static let movie = belongsTo(Movie.self)
}
