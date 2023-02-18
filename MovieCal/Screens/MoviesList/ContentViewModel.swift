//
//  ContentViewModel.swift
//  MovieCal
//
//  Created by Dylan Elliott on 18/2/2023.
//

import Foundation
import SwiftUI

struct Movie: Hashable {
    let id: Int
    let imageURL: URL
    let title: String
    let releaseDate: String
    let genreIDs: [Int]
}

struct CreditedMovie {
    let movie: Movie
    let credits: [(MoviePerson, [String])]
}

extension CreditedMovie {
    var creditsString: String {
        credits.map {
            "\($0.0.name) (\($0.1.joined(separator: ", ")))"
        }
        .joined(separator: ", ")
    }
}
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

struct MovieCredit {
    let movie: Movie
    let person: MoviePerson
}

class ContentViewModel: ObservableObject, FilterViewModelDelegate {
    let client = MovieClient.shared
    
    private var people: [MoviePerson] = []
    private var credits: [MovieCredit] = []
    private var genres: [MovieGenre] = []
    private var selectedGenres: [Int] = []
    @Published var peopleRows: [PersonCellModel] = []
    @Published var movieRows: [MovieCellModel] = []
    
    init() {
        getGenres()
    }
    
    private func getGenres() {
        client.getGenres { result in
            if case let .success(genres) = result {
                self.genres = genres
            }
        }
    }
    
    private func reloadCells() {
        var movies = Array(
            Set(
                self.credits.map { $0.movie }
            )
        )
        
        if !selectedGenres.isEmpty {
            movies = movies.filter { movie in
                movie.genreIDs.any { selectedGenres.contains($0) }
            }
        }
        
        self.movieRows = movies.map { movie in
            let credit = self.credits
                .filter { $0.movie.id == movie.id }.map { $0.person.name }.joined(separator: ", ")
            
            return .init(id: movie.id, imageURL: movie.imageURL, title: movie.title, credits: credit)
        }
        
        self.peopleRows = people.map { person in
                .init(
                    id: person.id,
                    imageURL: person.imageURL ?? Image.placeholderURL,
                    title: person.name
                )
        }
    }
    
    func didAddPerson(_ person: MoviePerson) {
        client.getCredits(for: person) { result in
            if case let .success(personCredits) = result {
                self.people.append(person)
                self.credits.append(contentsOf: personCredits.movies.map { .init(movie: $0, person: person) })
                
                onMain {
                    self.reloadCells()
                }
            }
        }
    }
    
    func filterViewModel() -> FilterViewModel {
        let movies = Array(Set(self.credits.map { $0.movie }))
        
        let filteredGenres: [MovieGenre] = Set(movies.flatMap {
            $0.genreIDs
        }).compactMap { genreID in
            self.genres.first(where: { $0.id == genreID })
        }
        
        return .init(genres: filteredGenres, selectedIDs: selectedGenres, delegate: self)
    }
    
    func didUpdateSelectedGenres(_ ids: [Int]) {
        selectedGenres = ids
        reloadCells()
    }
}


extension MovieCredits {
    var movies: [Movie] {
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
