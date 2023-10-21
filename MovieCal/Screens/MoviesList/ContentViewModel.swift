//
//  ContentViewModel.swift
//  MovieCal
//
//  Created by Dylan Elliott on 18/2/2023.
//

import Foundation
import SwiftUI
import GRDB

struct MovieCellModel: Identifiable {
    let id: Int
    let imageURL: URL
    let title: String
    let credits: String
    let numCredits: Int
    let toBeHidden: Bool
}

struct PersonCellModel: Identifiable {
    let id: Int
    let imageURL: URL
    let title: String
}

class ContentViewModel: ObservableObject, FilterViewModelDelegate {
    let client = MovieClient.shared
    private let database: Database
    
    private var genres: [Genre] = []
    private var selectedGenres: [Int] = []
    @Published var peopleRows: [PersonCellModel] = []
    @Published var movieRows: [MovieCellModel] = []
    
    @Published var filterViewModel: FilterViewModel?
    @Published var detailViewModel: MovieDetailViewModel?
    @Published var searchViewModel: SearchViewModel?
    @Published var hideViewModel: HideViewModel?
    
    @Published var showLoading: Bool = false
    
    @Published var hideMode: Bool = false
    @Published var moviesToHide: [Int] = []
    
    init(database: Database) {
        self.database = database
        getGenres()
    }
    
    func onAppear() {
        reloadCells()
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
            self.movieRows = await database.allCreditedMovies(includeHidden: false).filter { movie in
                guard !selectedGenres.isEmpty else { return true }
                return movie.genres.map { $0.id }.containsAll(in: selectedGenres)
            }.sorted(by: { $0.people.count > $1.people.count }).map { credit in
                .init(
                    id: credit.movie.id,
                    imageURL: credit.movie.imageURL,
                    title: credit.movie.title,
                    credits: credit.people.map { $0.name }.joined(separator: ", "),
                    numCredits: credit.people.count,
                    toBeHidden: hideMode && moviesToHide.contains(credit.movie.id)
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
    
    func didAddPerson(_ person: Person) {
        client.getCredits(for: person, genres: genres) { result in
            self.showLoading = true
            if case let .success(movies) = result {
                Task { @MainActor in
                    await self.database.createPerson(person, with: movies)
                    self.reloadCells()
                    self.showLoading = false
                }
            }
        }
    }
    
    func filterTapped() {
        Task { @MainActor in
            self.showLoading = true
            let genres = await database.allGenres()
            filterViewModel = .init(
                genres: genres,
                selectedIDs: selectedGenres,
                delegate: self
            )
            self.showLoading = false
        }
    }
    
    func searchTapped() {
        Task { @MainActor in
            searchViewModel = .init(
                known: await database.allPeople(),
                onSelect: { [weak self] in
                    self?.searchViewModel = nil
                    self?.didAddPerson($0)
                }
            )
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
        if hideMode {
            moviesToHide.append(movie.id)
            self.reloadCells()
        } else {
            showMovieDetail(movie)
        }
    }
    
    private func showMovieDetail(_ movie: MovieCellModel) {
        Task { @MainActor in
            showLoading = true
            guard let movie = await database.movie(with: movie.id) else { return }
            detailViewModel = .init(movie: movie, database: database, onUpdate: {
                self.reloadCells()
            }, dismiss: {
                self.reloadCells()
                self.detailViewModel = nil
            })
            showLoading = false
        }
    }
    
    func hideMoviesTapped() {
        Task { @MainActor in
            let movies = await database.allMovies().filter { moviesToHide.contains($0.id) }
            hideViewModel = .init(
                movies: movies,
                database: database,
                onUpdate: { },
                dismis: {
                    self.hideViewModel = nil
                }
            )
            hideMode = false
            moviesToHide = []
            reloadCells()
        }
    }
}


extension TMDBPersonCredits {
    var movies: [TMDBMovie] {
        Array(Set(cast.map { $0.movie }).union(Set(crew.map { $0.movie })))
     }
}

extension TMDBPersonCredits {
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
    
    func containsAll(in others: [Element]) -> Bool {
        others.allSatisfy { self.contains($0) }
    }
}
