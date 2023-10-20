//
//  TMDBPersonCredits.swift
//  MovieCal
//
//  Created by Dylan Elliott on 20/10/2023.
//

import Foundation

struct TMDBMovieCredits: Codable {
    let cast: [TMDBMovieCastCredit]
    let crew: [TMDBMovieCrewCredit]
}

protocol TMDBMovieCreditType {
    var id: Int { get }
    var name: String { get }
    var profile_path: String? { get }
    var role: String { get }
    var popularity: Float { get }
}

extension TMDBMovieCreditType {
    var imageURL: URL? {
        profile_path.map { TMDBAPI.image(String($0)).url }
    }
}

struct TMDBMovieCastCredit: TMDBMovieCreditType, Codable {
    let id: Int
    let name: String
    let profile_path: String?
    let character: String
    var role: String { character }
    var popularity: Float
}

struct TMDBMovieCrewCredit: TMDBMovieCreditType, Codable {
    let id: Int
    let name: String
    let profile_path: String?
    let department: String
    let job: String
    var role: String { "\(department): \(job)" }
    var popularity: Float
}
