//
//  HideViewModel.swift
//  MovieCal
//
//  Created by Dylan Elliott on 5/2/2025.
//

import Foundation

class HideViewModel: ObservableObject, Identifiable {
    let id: UUID = .init()
    
    let database: Database
    let client: MovieClient = .shared
    let onUpdate: () -> Void
    let dismis: () -> Void
    
    var movies: [MovieWithGenres]
    private var genres: [Genre] = []
    
    @Published var movie: MovieWithGenres?
    @Published var people: [Person] = []
    
    init(movies: [MovieWithGenres], database: Database, onUpdate: @escaping () -> Void, dismis: @escaping () -> Void) {
        self.database = database
        self.movies = movies
        self.dismis = dismis
        self.onUpdate = onUpdate
        loadNextMovie()
    }
    
    func loadNextMovie() {
        guard !movies.isEmpty else { return }
        
        let movie = movies.removeFirst()
        
        Task { @MainActor in
            if genres.isEmpty {
                genres = await database.allGenres()
            }
            
            let credited = try! await database.creditsForMovie(movie.movie)
            
            client.getCredits(for: movie.movie) { result in
                guard case let .success(people) = result else { return }
                let others = people.filter { !credited.people.contains($0) }
                
                onMain {
                    self.movie = movie
                    self.people = others
                }
            }
        }
    }
    
    func peopleSelected(_ people: [Person], hide: Bool) {
        people.forEach { person in
            client.getCredits(for: person, genres: genres) { result in
                guard case let .success(movies) = result else { return }
                
                Task { @MainActor in
                    await self.database.createPerson(person, with: movies)
                }
            }
        }
        
        Task { @MainActor in
            if hide {
                await self.database.hideMovie(self.movie!.movie)
            }
            
            self.onUpdate()
            self.nextMovie()
        }
    }
    
    private func nextMovie() {
        if movies.isEmpty {
            dismis()
        } else {
            loadNextMovie()
        }
    }
}
