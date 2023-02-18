//
//  MovieClient.swift
//  MovieCal
//
//  Created by Dylan Elliott on 18/2/2023.
//

import Foundation
import SwiftUI

class MovieClient {
    static var shared: MovieClient = .init()
    
    @discardableResult
    func searchPeople(for query: String, completion: @escaping APICompletion<[MoviePerson]>) -> URLSessionDataTask {
        TMDBAPI.searchPeople(query).retrieve(TMDBPagedResponse<MoviePerson>.self) { result in
            completion(result.map { $0.results })
        }
    }
    
    @discardableResult
    func getCredits(for person: MoviePerson, completion: @escaping APICompletion<MovieCredits>) -> URLSessionDataTask  {
        TMDBAPI.getCredits(person.id).retrieve(MovieCredits.self, completion: completion)
    }
    
    @discardableResult
    func getGenres(completion: @escaping APICompletion<[MovieGenre]>) -> URLSessionDataTask {
        TMDBAPI.genres.retrieve(TMDBGenresResponse.self) { result in
            completion(result.map { $0.genres })
        }
    }
}
