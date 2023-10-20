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
    let numCredits: Int
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

struct MovieDetailViewModel: Identifiable {
    let id: UUID = .init()
    let title: String
    let description: String
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
    @Published var detailViewModel: MovieDetailViewModel?
    @Published var showLoading: Bool = false
    
    init(database: Database) {
        self.database = database
        getGenres()
    }
    
    private func getGenres() {
        showLoading = true
        client.getGenres { result in
            if case let .success(genres) = result {
                self.genres = genres
                self.database.saveGenres(genres.map { .init(id: $0.id, name: $0.name) })
            }
            
            self.reloadCells()
            // Should be called, but we're not on main, so just leaving it
            // for the `reloadCells` to do
            // self.showLoading = false
        }
    }
    
    private func reloadCells() {
        Task { @MainActor in
            showLoading = true
            self.movieRows = await database.allCreditedMovies().filter { movie in
                guard !selectedGenres.isEmpty else { return true }
                return selectedGenres.containsAny(movie.genres.map { $0.id })
            }.sorted(by: { $0.credits.count > $1.credits.count }).map { credit in
                .init(
                    id: credit.movie.id,
                    imageURL: credit.movie.imageURL,
                    title: credit.movie.title,
                    credits: credit.credits.map { $0.name }.joined(separator: ", "),
                    numCredits: credit.credits.count
                )
            }
            self.peopleRows = await database.allPeople().map { person in
                .init(
                    id: person.id,
                    imageURL: person.imageURL ?? Image.placeholderURL,
                    title: person.name
                )
            }
            
            showLoading = false
        }
    }
    
    func didAddPerson(_ person: MoviePerson) {
        
        let domain = Person(id: person.id, name: person.name, imageURL: person.imageURL)
        
        client.getCredits(for: person) { result in
            self.showLoading = true
            if case let .success(personCredits) = result {
                Task { @MainActor in
                    await self.database.createPerson(domain)
                    await self.database.saveMovies(personCredits.movies.map {
                        .init(
                            id: $0.id,
                            imageURL: $0.imageURL,
                            title: $0.title,
                            overview: $0.overview
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
                    self.showLoading = false
                }
            }
        }
    }
    
    func filterTapped() {
        Task { @MainActor in
            self.showLoading = true
            let movies: [CreditedMovie] = await database.allCreditedMovies()
            let filteredGenres: [Genre] = Array(Set(movies.flatMap { $0.genres }))
            filterViewModel = .init(genres: filteredGenres, selectedIDs: selectedGenres, delegate: self)
            self.showLoading = false
        }
    }

    func didUpdateSelectedGenres(_ ids: [Int]) {
        showLoading = true
        selectedGenres = ids
        reloadCells()
        showLoading = false
    }
    
    func deletePerson(_ person: PersonCellModel) {
        Task { @MainActor in
            showLoading = true
            let people = await database.allPeople()
            guard let person = people.first(where: { $0.id == person.id }) else { return }
            await database.deletePerson(person)
            reloadCells()
            showLoading = false
        }
    }
    
    func movieTapped(_ movie: MovieCellModel) {
        Task { @MainActor in
            showLoading = true
            let movies = await database.allCreditedMovies()
            guard let movie = movies.first(where: { $0.movie.id == movie.id }) else { return }
            detailViewModel = .init(
                title: movie.movie.title, description: movie.movie.overview
            )
            showLoading = false
        }
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
