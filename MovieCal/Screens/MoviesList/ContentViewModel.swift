//
//  ContentViewModel.swift
//  MovieCal
//
//  Created by Dylan Elliott on 18/2/2023.
//

import Foundation
import SwiftUI
import GRDB


//struct CreditedMovie {
//    let movie: Movie
//    let credits: [(MoviePerson, [String])]
//}
//
//extension CreditedMovie {
//    var creditsString: String {
//        credits.map {
//            "\($0.0.name) (\($0.1.joined(separator: ", ")))"
//        }
//        .joined(separator: ", ")
//    }
//}

struct MovieCellModel: Identifiable {
    let id: Int
    let imageURL: URL
    let title: String
    let credits: String
}

struct PersonCellModel: Identifiable {
    let id: Int
    let imageURL: URL
    let title: String
}

struct TMDBMovieCredit {
    let movie: Movie
    let person: MoviePerson
}

class ContentViewModel: ObservableObject, FilterViewModelDelegate {
    let client = MovieClient.shared
    private let database: Database
    
//    private var people: [MoviePerson] = []
//    private var credits: [TMDBMovieCredit] = []
    private var genres: [TMDBGenre] = []
    private var selectedGenres: [Int] = []
    @Published var peopleRows: [PersonCellModel] = []
    @Published var movieRows: [MovieCellModel] = []
    @Published var filterViewModel: FilterViewModel?
    
    init(database: Database) {
        self.database = database
        getGenres()
    }
    
    private func getGenres() {
        client.getGenres { result in
            if case let .success(genres) = result {
                self.genres = genres
                self.database.saveGenres(genres.map { .init(id: $0.id, name: $0.name) })
            }
            
            self.reloadCells()
        }
    }
    
    private func reloadCells() {
        Task { @MainActor in 
            self.movieRows = await database.allCreditedMovies().filter { movie in
                guard !selectedGenres.isEmpty else { return true }
                return selectedGenres.containsAny(movie.genres.map { $0.id })
            }.map { credit in
                .init(
                    id: credit.movie.id,
                    imageURL: credit.movie.imageURL,
                    title: credit.movie.title,
                    credits: credit.credits.map { $0.name }.joined(separator: ", ")
                )
            }
            self.peopleRows = await database.allPeople().map { person in
                .init(
                    id: person.id,
                    imageURL: person.imageURL ?? Image.placeholderURL,
                    title: person.name
                )
            }
        }
    }
    
    func didAddPerson(_ person: MoviePerson) {
        
        let domain = Person(id: person.id, name: person.name, imageURL: person.imageURL)
        
        client.getCredits(for: person) { result in
            if case let .success(personCredits) = result {
                Task { @MainActor in
                    await self.database.createPerson(domain)
                    await self.database.saveMovies(personCredits.movies.map {
                        .init(
                            id: $0.id,
                            imageURL: $0.imageURL,
                            title: $0.title
                        )
                    })
                    await self.database.saveCredits(personCredits.cast.map {
                        .init(personId: Int64(person.id), movieId: Int64($0.movie.id))
                    })
                    await self.database.saveGenres(personCredits.movies.flatMap { movie in
                        movie.genreIDs.map {
                            .init(movieId: movie.id, genreId: $0)
                        }
                    })
                    
                    self.reloadCells()
                }
            }
        }
    }
    
    func filterTapped() {
        Task { @MainActor in
            let movies: [CreditedMovie] = await database.allCreditedMovies()
            let filteredGenres: [Genre] = Array(Set(movies.flatMap { $0.genres }))
            filterViewModel = .init(genres: filteredGenres, selectedIDs: selectedGenres, delegate: self)
        }
    }

    func didUpdateSelectedGenres(_ ids: [Int]) {
        selectedGenres = ids
        reloadCells()
    }
}


extension MovieCredits {
    var movies: [TMDBMovie] {
        Array(Set(cast.map { $0.movie }).union(Set(crew.map { $0.movie })))
     }
}

extension MovieCredits {
    func credits(for movie: Movie) -> [String] {
        cast.credits(for: movie) + crew.credits(for: movie)
    }
}

extension Array {
    func any(_ condition: (Element) -> Bool) -> Bool {
        if first(where: { condition($0) }) != nil {
            return true
        } else {
            return false
        }
    }
}

extension Array where Element: Equatable {
    func containsAny(_ others: [Element]) -> Bool {
        self.any { element in
            others.contains(element)
        }
    }
}
