//
//  CreditedMovie.swift
//  MovieCal
//
//  Created by Dylan Elliott on 20/10/2023.
//

import Foundation
import GRDB

struct CreditedMovie: FetchableRecord, Codable, TableRecord {
    let movie: Movie
    let genres: [Genre]
    let people: [Person]
}
