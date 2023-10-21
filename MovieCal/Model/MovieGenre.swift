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
    
    static let movie = belongsTo(Movie.self)
    static let genre = belongsTo(Genre.self)
}

struct MovieWithGenres: FetchableRecord, Codable {
    let movie: Movie
    let genres: [Genre]
    
    var id: Int { movie.id }
    var imageURL: URL { movie.imageURL }
    var title: String { movie.title }
    var overview: String { movie.overview }
}
