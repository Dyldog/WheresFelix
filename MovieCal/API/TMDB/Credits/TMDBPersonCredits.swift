//
//  MovieCredits.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation

struct TMDBPersonCredits: Decodable {
    let crew: [TMDBPersonCrewCredit]
    let cast: [TMDBPersonCastCredit]
}

extension TMDBPersonCredits {
    var movies: [TMDBMovie] {
        Array(Set(cast.map { $0.movie }).union(Set(crew.map { $0.movie })))
     }
}

extension TMDBPersonCredits {
    func credits(for movie: Movie) -> [String] {
        cast.credits(for: movie) + crew.credits(for: movie)
    }
}
