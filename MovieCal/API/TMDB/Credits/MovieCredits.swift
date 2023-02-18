//
//  MovieCredits.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation

struct MovieCredits: Decodable {
    let crew: [MovieCrewCredit]
    let cast: [MovieCastCredit]
}
