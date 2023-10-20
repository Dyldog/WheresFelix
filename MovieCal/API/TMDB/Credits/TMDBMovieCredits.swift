//
//  MovieCredits.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation

struct TMDBMovieCredits: Decodable {
    let crew: [TMDBMovieCrewCredit]
    let cast: [TMDBMovieCastCredit]
}
