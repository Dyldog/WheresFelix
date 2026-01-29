//
//  MovieClient.swift
//  MovieCal
//
//  Created by Dylan Elliott on 18/2/2023.
//

import Foundation
import SwiftUI
import DylKit
import DylKitAPI

class MovieClient {
    static var shared: MovieClient = .init()
    
    private let releaseDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    @discardableResult
    func searchPeople(for query: String, completion: @escaping APICompletion<[Person]>) -> Task<Void, Never> {
        TMDBJSONAPI.searchPeople.retrieve(.init(query)) { result in
            completion(
                result.map { result in
                    result.map {
                        .init(id: $0.id, name: $0.name, imageURL: $0.imageURL)
                    }
                }.mapError {
                    .unknown($0)
                }
            )
        }
    }
    
    @discardableResult
    func getCredits(for person: Person, genres: [Genre], completion: @escaping APICompletion<[MovieWithGenres]>) -> Task<Void, Never>  {
        TMDBJSONAPI.getCredits.retrieve(.init(actorID: person.id)) { [weak self] result in
            guard let self else { return }
            
            completion(
                result.map { credits in
                    credits.movies.compactMap {
                        guard let releaseDate = self.releaseDateFormatter.date(from: $0.releaseDate) else {
                            print("ERROR: Movie \($0.title) (\($0.id)) has missing or invalid release date: \($0.releaseDate)")
                            return nil
                        }
                        
                        return .init(
                            movie: .init(
                                id: $0.id,
                                imageURL: $0.imageURL,
                                title: $0.title,
                                overview: $0.overview,
                                releaseDate: releaseDate
                            ),
                            genres: $0.genreIDs.map { id in genres.first(where: { $0.id == id })! }
                        )
                    }
                }.mapError {
                    .unknown($0)
                }
            )
        }
    }
    
    @discardableResult
    func getCredits(for movie: Movie, completion: @escaping APICompletion<[Person]>) -> Task<Void, Never> {
        TMDBJSONAPI.getMovieCredits.retrieve(.init(movieID: movie.id)) { result in
            completion(result.map { credits in
                let people: [TMDBMovieCreditType] = (credits.cast + credits.crew).sorted(by: {
                    $0.popularity > $1.popularity
                })
                
                return people.map {
                    Person(id: $0.id, name: $0.name, imageURL: $0.imageURL)
                }
                .unique
            }.mapError {
                .unknown($0)
            })
        }
    }
    
    @discardableResult
    func getGenres(completion: @escaping APICompletion<[Genre]>) -> Task<Void, Never> {
        TMDBJSONAPI.getGenres.retrieve() { result in
            completion(result.map { result in result.genres.map {
                .init(id: $0.id, name: $0.name)
            }}.mapError {
                .unknown($0)
            })
        }
    }
}
