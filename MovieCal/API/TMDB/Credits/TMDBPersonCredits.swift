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
