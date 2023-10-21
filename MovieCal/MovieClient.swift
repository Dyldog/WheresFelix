//
//  MovieClient.swift
//  MovieCal
//
//  Created by Dylan Elliott on 18/2/2023.
//

import Foundation
import SwiftUI
import DylKit

class MovieClient {
    static var shared: MovieClient = .init()
    
    @discardableResult
    func searchPeople(for query: String, completion: @escaping APICompletion<[Person]>) -> URLSessionDataTask {
        TMDBAPI.searchPeople(query).retrieve(TMDBPagedResponse<TMDBMoviePerson>.self) { result in
            completion(result.map { result in result.results.map {
                .init(id: $0.id, name: $0.name, imageURL: $0.imageURL)
            }})
        }
    }
    
    @discardableResult
    func getCredits(for person: Person, genres: [Genre], completion: @escaping APICompletion<[MovieWithGenres]>) -> URLSessionDataTask  {
        TMDBAPI.getCredits(person.id).retrieve(TMDBPersonCredits.self) { result in
            completion(result.map { credits in
                credits.movies.map {
                    .init(
                        movie: .init(
                            id: $0.id,
                            imageURL: $0.imageURL,
                            title: $0.title,
                            overview: $0.overview
                        ),
                        genres: $0.genreIDs.map { id in genres.first(where: { $0.id == id })! }
                    )
                }
            })
        }
    }
    
    @discardableResult
    func getCredits(for movie: Movie, completion: @escaping APICompletion<[Person]>) -> URLSessionDataTask {
        TMDBAPI.movieCredits(movie.id).retrieve(TMDBMovieCredits.self) { result in
            completion(result.map { credits in
                let people: [TMDBMovieCreditType] = (credits.cast + credits.crew).sorted(by: {
                    $0.popularity > $1.popularity
                })
                
                return people.map {
                    Person(id: $0.id, name: $0.name, imageURL: $0.imageURL)
                }
                .unique
            })
        }
    }
    
    @discardableResult
    func getGenres(completion: @escaping APICompletion<[Genre]>) -> URLSessionDataTask {
        TMDBAPI.genres.retrieve(TMDBGenresResponse.self) { result in
            completion(result.map { result in result.genres.map {
                .init(id: $0.id, name: $0.name)
            }})
        }
    }
}
