//
//  TMDBGenresResponse.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation

struct TMDBGenresResponse: Decodable {
    let genres: [MovieGenre]
}
