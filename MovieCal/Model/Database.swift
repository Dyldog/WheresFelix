//
//  Database.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation
import GRDB
import CollectionConcurrencyKit
import DylKit

private struct DBMovie: Hashable, Codable, FetchableRecord, PersistableRecord {
    let id: Int
    let imageURL: URL
    let title: String
    let overview: String
}

private extension Movie {
    var dbMovie: DBMovie {
        .init(id: self.id, imageURL: self.imageURL, title: self.title, overview: self.overview)
    }
}

class Database {
    private let dbWriter: DatabaseWriter
    
    init() throws {
        self.dbWriter = try Self.createDB()
        try! self.migrator.migrate(self.dbWriter)
    }
    
    private static func createDB() throws -> DatabaseWriter {
        let fileManager = FileManager()
        let folderURL = try fileManager
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("database", isDirectory: true)
        try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        let dbURL = folderURL.appendingPathComponent("db.sqlite")
//        try fileManager.removeItem(at: dbURL)
        let dbPool = try DatabasePool(path: dbURL.path)
        return dbPool
    }
    
    func saveGenres(_ genres: [Genre]) {
        try! dbWriter.write { db in
            try genres.forEach {
                try $0.insert(db, onConflict: .ignore)
            }
        }
    }
    
    private func makeMovieFromDBVersion(_ dbMovie: DBMovie) async -> Movie {
        try! await dbWriter.read { db in
            let genreMap = try MovieGenre
                .filter(Column("movieId") == dbMovie.id)
                .fetchAll(db)
            
            let genres = try genreMap.map {
                try Genre.find(db, key: $0.genreId)
            }
            
            return .init(
                id: dbMovie.id,
                imageURL: dbMovie.imageURL,
                title: dbMovie.title,
                overview: dbMovie.overview,
                genres: genres
            )
        }
    }
    
    func allPeople() async -> [Person] {
        try! await dbWriter.read { db in
            return try Person.fetchAll(db)
        }
    }
    
    func movie(with id: Int) async -> Movie? {
        func getMovie() async -> DBMovie? {
            try! await dbWriter.read({ db in
                return try DBMovie.filter(Column("id") == id).fetchOne(db)
            })
        }
        
        let genres = await allGenres()
        
        return await getMovie().asyncMap { await makeMovieFromDBVersion($0) }
    }
    
    func allMovies() async -> [Movie] {
        func dbMovies() async -> [DBMovie] {
            try! await dbWriter.read { db in
                return try DBMovie.fetchAll(db)
            }
        }
        
        return await dbMovies().asyncMap { await makeMovieFromDBVersion($0) }
        
    }
    
    func allGenres() async -> [Genre] {
        try! await dbWriter.read { db in
            return try Genre.fetchAll(db)
        }
    }
    
    private func creditsForMovie(_ movie: Movie, db: GRDB.Database) throws -> CreditedMovie {
        let credits = try PersonMovie
            .filter(Column("movieId") == movie.id)
            .fetchAll(db)
        
        let actors = try credits.map {
            try Person.find(db, key: $0.personId)
        }
        
        return CreditedMovie(movie: movie, credits: actors)
    }
    
    func creditsForMovie(_ movie: Movie) async throws -> CreditedMovie {
        do {
            return try await dbWriter.write({ db in
                return try self.creditsForMovie(movie, db: db)
            })
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func allCreditedMovies(includeHidden: Bool = true) async -> [CreditedMovie] {
        let movies = await allMovies()
        do {
            return try await dbWriter.write { db in
                var movies = movies
                
                if !includeHidden {
                    let hidden = try HiddenMovie.fetchAll(db).map { $0.movieId }
                    movies = includeHidden ? movies : movies.filter { !hidden.contains($0.id) }
                }
                
                return try movies.map { movie in
                    try self.creditsForMovie(movie, db: db)
                }
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func createPerson(_ person: Person, with movies: [Movie]) async {
        try! await dbWriter.write { db in
            try person.insert(db)
            try movies.forEach { movie in
                try movie.dbMovie.insert(db, onConflict: .ignore)
                try movie.genres.forEach { genre in
                    try MovieGenre(movieId: movie.id, genreId: genre.id).insert(db, onConflict: .ignore)
                }
                try PersonMovie(personId: Int64(person.id), movieId: Int64(movie.id))
                    .insert(db, onConflict: .ignore)
            }
        }
    }
    
    private func deleteMovie(_ movie: Movie) async {
        do {
            _ = try await dbWriter.write { db in
                try movie.dbMovie.delete(db)
                try MovieGenre.filter(Column("movieId") == movie.id).deleteAll(db)
                try PersonMovie.filter(Column("movieId") == movie.id).deleteAll(db)
            }
        } catch {
            print(error)
        }
    }
    
    private func deleteMoviesWithoutPeople() async {
        let movies = await allCreditedMovies().filter { $0.credits.count == 0 }
        
        await movies.asyncForEach { movie in
            await deleteMovie(movie.movie)
        }
    }
    
    func deletePerson(_ person: Person) async {
        do {
            _ = try await dbWriter.write { db in
                try person.delete(db)
            }
            
            await deleteMoviesWithoutPeople()
        } catch {
            print(error)
        }
    }
}

// MARK: - Hiding

extension Database {
    func hideMovie(_ movie: Movie) async {
        do {
            _ = try await dbWriter.write { db in
                try HiddenMovie(movieId: movie.id).insert(db, onConflict: .ignore)
            }
        } catch {
            print(error)
        }
    }
}
