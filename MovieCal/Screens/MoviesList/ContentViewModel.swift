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

class ContentViewModel: ObservableObject {
    let client = MovieClient.shared
    private let database: Database
    private let notes: NotesClient = .shared
    
    private var minimumPeople = FilterViewModel.lowestMinimumActorCount
    private var genres: [Genre] = []
    private var selectedGenres: [Int] = []
    private var movieNotes: [MovieNote] = []
    
    @Published var peopleRows: [PersonCellModel] = []
    @Published var movieRows: [MovieCellModel] = []
    @Published var noterows: [NotePersonModel] = []
    
    @Published var filterViewModel: FilterViewModel?
    @Published var detailViewModel: MovieDetailViewModel?
    @Published var searchViewModel: SearchViewModel?
    @Published var hideViewModel: HideViewModel?
    @Published var showSortOrderSheet: Bool = false
    
    @Published var showLoading: Bool = false
    var showNotes: Bool { !notes.hasSelectedDirectory }
    
    @Published var hideMode: Bool = false
    @Published var moviesToHide: [Int] = []
    @Published var sortOrder: SortOrder = .releaseDate
    @Published var sortAscending: Bool = false
    @Published var hideUnreleased: Bool = true
    @Published var excludeSelectedGenres: Bool = false
    
    init(database: Database) {
        self.database = database
        onAppear()
    }
    
    func onAppear() {
        showLoading = true
        
        if genres.isEmpty {
            getGenres()
        }
        
        if notes.hasSelectedDirectory {
            movieNotes = notes.movieNotes()
            noterows = movieNotes.grouping(by: { $0.actors }).map { entry in
                .init(name: entry.key, movies: entry.value.map { $0.title })
            }
        }
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
    
    private func reloadCells() {
        Task { @MainActor in
            showLoading = true
            self.movieRows = await visibleMovies().map { credit in
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
                    self.hideViewModel = nil
                }
            )
            hideMode = false
            moviesToHide = []
            reloadCells()
        }
    }
    
    func sortButtonTapped() {
        showSortOrderSheet = true
    }
    
    func didSelectSortOrderToggle() {
        sortAscending.toggle()
        reloadCells()
    }
    
    func didSelectSortOrder(_ order: SortOrder) {
        showLoading = true
        sortOrder = order
        reloadCells()
        showLoading = false
    }
}

// MARK: - Sorting

extension ContentViewModel {
    enum SortOrder: String, CaseIterable, Identifiable {
        case peopleCount
        case releaseDate
        
        var id: String { rawValue }
        
        var title: String {
            switch self {
            case .peopleCount: "Number of people"
            case .releaseDate: "Release date"
            }
        }
        
        func orderedAscending(lhs: CreditedMovie, rhs: CreditedMovie) -> Bool {
            switch self {
            case .peopleCount: return lhs.people.count < rhs.people.count
            case .releaseDate: return lhs.movie.releaseDate < rhs.movie.releaseDate
            }
        }
    }
}

extension Array where Element == CreditedMovie {
    func sorted(in order: ContentViewModel.SortOrder, ascending: Bool) -> Self {
        sorted(by: { order.orderedAscending(lhs: $0, rhs: $1) }, ascending: ascending)
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

// MARK: - Notes

extension ContentViewModel {
    func didSelectNotesFolder(_ url: URL) {
        notes.setDirectory(url)
        onAppear()
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
