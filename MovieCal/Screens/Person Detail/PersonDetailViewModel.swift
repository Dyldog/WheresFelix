//
//  PersonDetailViewModel.swift
//  MovieCal
//
//  Created by Dylan Elliott on 5/2/2025.
//

import SwiftUI

class PersonDetailViewModel: ObservableObject, NotesViewModel, Identifiable, MovieSortingViewModel {
    private let database: Database
    let notes: NotesClient = .shared
    
    private let person: PersonCellModel
    private var movieNotes: [MovieNote] = []
    
    @Published var movieRows: [MovieCellModel] = []
    @Published var detailViewModel: MovieDetailViewModel?
    @Published var showLoading: Bool = false
    @Published var sortOrder: MovieSortOrder = .releaseDate
    @Published var sortAscending: Bool = false
    
    var id: Int { person.id }
    var title: String { person.title }

    init(database: Database, person: PersonCellModel) {
        self.database = database
        self.person = person
        
        showLoading = true
        
        Task {
            loadNotes()
        }
    }

    func onLoadNotes() {
        Task { @MainActor in
            showLoading = true
        }
        
        Task {
            movieNotes = notes.movieNotes()
            reload()
        }
    }
    
    func reload() {
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
                    toBeHidden: false
                )
            }
            
            Task { @MainActor in
                movieRows = newRows
                showLoading = false
            }
        }
    }
    
    private func visibleMovies() async -> [CreditedMovie] {
        let noteMovieTitles = movieNotes.map { $0.title }
        return await database.allCreditedMovies(excludingTitles: noteMovieTitles, includeHidden: false).filter {
            $0.people.contains(where: { person in person.id == self.person.id })
        }
        .sorted(in: sortOrder, ascending: sortAscending)
    }
    
    private func showMovieDetail(_ movie: MovieCellModel) {
        showLoading = true
        
        Task {
            guard let movie = await database.movie(with: movie.id) else { return }
            detailViewModel = .init(movie: movie, database: database, onUpdate: {
                self.reload()
            }, dismiss: {
                self.reload()
                self.detailViewModel = nil
            })
            
            Task { @MainActor in
                showLoading = false
            }
        }
    }
    
    func movieTapped(_ movie: MovieCellModel) {
        showMovieDetail(movie)
    }
}
