//
//  DetailViewModel.swift
//  MovieCal
//
//  Created by Dylan Elliott on 20/10/2023.
//

import SwiftUI

class MovieDetailViewModel: ObservableObject, Identifiable {
    let client = MovieClient.shared
    private let database: Database
    
    let id: UUID = .init()
    let movie: MovieWithGenres
    
    var title: String { movie.title }
    var description: String {
        return """
        \(movie.genres.unique.map { $0.name }.joined(separator: ", "))
        \(movie.overview)
        """
        
        
    }
    @Published var knownActors: [Person] = []
    @Published var otherActors: [Person] = []
    let onUpdate: () -> Void
    let dismiss: () -> Void
    
    private var genres: [Genre] = []
    
    @Published var personDetailViewModel: PersonDetailViewModel?
    
    init(movie: MovieWithGenres, database: Database, onUpdate: @escaping () -> Void, dismiss: @escaping () -> Void) {
        self.movie = movie
        self.database = database
        self.onUpdate = onUpdate
        self.dismiss = dismiss
        load()
    }
    
    private func load() {
        Task { @MainActor in
            genres = await database.allGenres()
            let credited = try! await database.creditsForMovie(movie.movie)
            client.getCredits(for: movie.movie) { result in
                guard case let .success(credits) = result else { return }
                
                onMain {
                    self.knownActors = credited.people
                    self.otherActors = credits.filter { !self.knownActors.contains($0) }
                }
            }
        }
    }
    
    func knownPersonTapped(_ person: Person) {
        personDetailViewModel = .init(
            database: database,
            person: .init(id: person.id, imageURL: person.imageURL ?? Image.placeholderURL, title: person.name)
        )
    }
    
    func personTapped(_ person: Person) {
        client.getCredits(for: person, genres: genres) { result in
            guard case let .success(movies) = result else { return }
            
            Task { @MainActor in
                await self.database.createPerson(person, with: movies)
                self.otherActors.removeAll(where: { $0.id == person.id })
                self.knownActors.insert(person, at: 0)
                self.onUpdate()
            }
        }
    }
    
    func hideTapped() {
        Task { @MainActor in
            await database.hideMovie(movie.movie)
            self.dismiss()
        }
    }
}
