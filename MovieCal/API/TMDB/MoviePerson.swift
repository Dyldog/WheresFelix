//
//  MoviePerson.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation

struct MoviePerson: Decodable {
    let id: Int
    let name: String
    let profile_path: String?
}

extension MoviePerson {
    var imageURL: URL? {
        profile_path.map { TMDBAPI.image(String($0.trimmingPrefix("/"))).url }
    }
}
