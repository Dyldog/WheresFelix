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
    func searchPeople(for query: String, completion: @escaping APICompletion<[TMDBMoviePerson]>) -> URLSessionDataTask {
        TMDBAPI.searchPeople(query).retrieve(TMDBPagedResponse<TMDBMoviePerson>.self) { result in
            completion(result.map { $0.results })
        }
    }
    
    @discardableResult
    func getCredits(for person: TMDBMoviePerson, completion: @escaping APICompletion<TMDBMovieCredits>) -> URLSessionDataTask  {
        TMDBAPI.getCredits(person.id).retrieve(TMDBMovieCredits.self, completion: completion)
    }
    
    @discardableResult
    func getGenres(completion: @escaping APICompletion<[TMDBGenre]>) -> URLSessionDataTask {
        TMDBAPI.genres.retrieve(TMDBGenresResponse.self) { result in
            completion(result.map { $0.genres })
        }
    }
}
