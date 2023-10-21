//
//  Movie.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation
import GRDB

struct Movie: Hashable, Codable, TableRecord, EncodableRecord, PersistableRecord {
    let id: Int
    let imageURL: URL
    let title: String
    let overview: String
    
    private static let genreIDs = hasMany(MovieGenre.self)
    static let genres = hasMany(Genre.self, through: genreIDs, using: MovieGenre.genre)
    var genres: QueryInterfaceRequest<Genre> { request(for: Movie.genres) }
    
    private static let peopleIDs = hasMany(PersonMovie.self)
    static let people = hasMany(Person.self, through: peopleIDs, using: PersonMovie.person)
    
    static let hidden = hasOne(HiddenMovie.self)
}
