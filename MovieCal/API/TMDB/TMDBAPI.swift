//
//  TMDB.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation

enum TMDBAPI: API {
    var baseURL: URL {
        switch self {
        case .image: return .init(string: "https://image.tmdb.org/t/p/w500/")!
        default: return .init(string: "https://api.themoviedb.org/3")!
        }
    }
    
    static var defaultParameters: [String: String] = ["api_key": "a017696cd2e9070df7697cbe337393c5"]
    
    case searchPeople(String)
    case getCredits(Int)
    case image(String)
    case genres
    
    var path: String {
        switch self {
        case .searchPeople: return "/search/person"
        case .getCredits(let id): return "/person/\(id)/movie_credits"
        case .image(let path): return path
        case .genres: return "/genre/movie/list"
        }
    }
    
    var parameters: [String : String] {
        switch self {
        case .searchPeople(let query): return ["query": query]
        case .getCredits: return [:]
        case .image: return [:]
        case .genres: return [:]
        }
    }
}
