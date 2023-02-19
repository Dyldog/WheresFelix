//
//  MovieCrewCredit.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation

struct MovieCrewCredit: Decodable, MovieCreditType {
    let id: Int
    let title: String
    let department: String
    let overview: String
    let release_date: String
    var poster_path: String?
    var genre_ids: [Int]
    
    var role: String { department }
}
