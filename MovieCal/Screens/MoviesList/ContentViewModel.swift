//
//  ContentViewModel.swift
//  MovieCal
//
//  Created by Dylan Elliott on 18/2/2023.
//

import Foundation
import SwiftUI
import GRDB
import DylKit

struct PersonCellModel: Identifiable {
    let id: Int
    let imageURL: URL
    let title: String
}

class ContentViewModel: ObservableObject, NotesViewModel, MovieSortingViewModel {
    let client = MovieClient.shared
    private let database: Database
    let notes: NotesClient = .shared
    
    private var minimumPeople = FilterViewModel.lowestMinimumActorCount
    private var genres: [Genre] = []
    private var selectedGenres: [Int] = []
    private var movieNotes: [MovieNote] = []
    
    @Published var movieRows: [MovieCellModel] = []
    
    @Published var filterViewModel: FilterViewModel?
    @Published var detailViewModel: MovieDetailViewModel?
    @Published var searchViewModel: SearchViewModel?
    @Published var hideViewModel: HideViewModel?

    @Published var showLoading: Bool = false
    var showNotes: Bool { !notes.hasSelectedDirectory }
    
    @Published var hideMode: Bool = false
    @Published var moviesToHide: [Int] = []
    @Published var sortOrder: MovieSortOrder = .releaseDate
    @Published var sortAscending: Bool = false
    @Published var hideUnreleased: Bool = true
    @Published var excludeSelectedGenres: Bool = false
    
    var peopleViewModel: PeopleViewModel {
        .init(database: database)
    }
    
    init(database: Database) {
        self.database = database
        onAppear()
    }
    
    func onAppear() {
        showLoading = true
        
        Task { @MainActor in
            if genres.isEmpty {
                getGenres()
            }
            
            loadNotes()
        }
    }
    
    func onLoadNotes() {
        movieNotes = notes.movieNotes()
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
    
    private func visibleMovies() async -> [CreditedMovie] {
        let noteMovieTitles = movieNotes.map { $0.title }
        return await database.allCreditedMovies(excludingTitles: noteMovieTitles, includeHidden: false).filter { movie in
            guard !selectedGenres.isEmpty else { return true }
            
            if excludeSelectedGenres {
                return movie.genres.map { $0.id }.containsAny(selectedGenres) == false
            } else {
                return movie.genres.map { $0.id }.containsAll(in: selectedGenres)
            }
        }
        .filter {
            $0.people.count >= minimumPeople &&
            (hideUnreleased ? ($0.movie.releaseDate < .now) : true)
        }
        .sorted(in: sortOrder, ascending: sortAscending)
    }
    
    func reloadCells() {
        Task { @MainActor in
            showLoading = true
        }
        
        Task {
            let newRows: [MovieCellModel] = await visibleMovies().map { credit in
                .init(
                    id: credit.movie.id,
                    imageURL: credit.movie.imageURL,
                    title: credit.movie.title,
                    credits: credit.people.map { $0.name }.joined(separator: ", "),
                    numCredits: credit.people.count,
                    toBeHidden: hideMode && moviesToHide.contains(credit.movie.id)
                )
            }
            
            Task { @MainActor in
                movieRows = newRows
                showLoading = false
            }
        }
    }
    
    func didAddPerson(_ person: Person) {
        self.showLoading = true
        client.getCredits(for: person, genres: genres) { result in
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
                minimumActors: minimumPeople, 
                hideUnreleased: hideUnreleased,
                genres: genres,
                selectedIDs: selectedGenres, 
                excludeGenres: excludeSelectedGenres,
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

    func movieTapped(_ movie: MovieCellModel) {
        if hideMode {
            if moviesToHide.contains(movie.id) {
                moviesToHide.removeAll { $0.id == movie.id }
            } else {
                moviesToHide.append(movie.id)
            }
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
            let allMovies = await visibleMovies().map { MovieWithGenres(movie: $0.movie, genres: $0.genres) }
            let movies = moviesToHide.isEmpty ? allMovies : allMovies.filter { moviesToHide.contains($0.id) }
            hideViewModel = .init(
                movies: movies,
                database: database,
                onUpdate: { },
                dismis: {
                    self.reloadCells()
                    self.hideViewModel = nil
                }
            )
            hideMode = false
            moviesToHide = []
            reloadCells()
        }
    }
}

// MARK: - Filtering

extension ContentViewModel: FilterViewModelDelegate {
    func didUpdateFilter(_ model: FilterViewModel) {
        showLoading = true
        
        minimumPeople = model.minimumActors
        selectedGenres = model.selectedIDs
        hideUnreleased = model.hideUnreleased
        excludeSelectedGenres = model.excludeGenres
        
        reloadCells()
        showLoading = false
    }
}

extension Sequence {
    func grouping<T>(by grouper: (Element) -> [T]) -> [T: [Element]] {
        return self.reduce(into: [:]) { partialResult, element in
            grouper(element).forEach {
                partialResult[$0, default: []].append(element)
            }
        }
    }
}
