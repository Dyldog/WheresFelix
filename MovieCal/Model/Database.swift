//
//  Database.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation
import GRDB
import CollectionConcurrencyKit

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
        try fileManager.removeItem(at: dbURL)
        let dbPool = try DatabasePool(path: dbURL.path)
        return dbPool
    }
    
    func saveGenres(_ genres: [Genre]) {
        try! dbWriter.write { db in
            _ = try Genre.deleteAll(db)
            try genres.forEach {
                try $0.insert(db)
            }
        }
    }
    
    func allPeople() async -> [Person] {
        try! await dbWriter.read { db in
            return try Person.fetchAll(db)
        }
    }
    
    func allMovies() async -> [Movie] {
        try! await dbWriter.read { db in
            return try Movie.fetchAll(db)
        }
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
        
        let genreMap = try MovieGenre
            .filter(Column("movieId") == movie.id)
            .fetchAll(db)
        
        let actors = try credits.map {
            try Person.find(db, key: $0.personId)
        }
        
        let genres = try genreMap.map {
            try Genre.find(db, key: $0.genreId)
        }
        
        return CreditedMovie(movie: movie, credits: actors, genres: genres)
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
    
    func allCreditedMovies() async -> [CreditedMovie] {
        do {
            return try await dbWriter.write { db in
                let movies = try Movie.fetchAll(db)
                return try movies.map { movie in
                    try self.creditsForMovie(movie, db: db)
                }
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func createPerson(_ person: Person) async {
        try! await dbWriter.write { db in
            try person.insert(db)
        }
    }
    
    func saveMovies(_ movies: [Movie]) async {
        try! await dbWriter.write { db in
            try movies.forEach {
                try $0.insert(db, onConflict: .ignore)
            }
        }
    }
    
    func saveCredits(_ credits: [PersonMovie]) async {
        do {
            try await dbWriter.write { db in
                try credits.forEach {
                    try $0.insert(db, onConflict: .ignore)
                }
            }
        } catch {
            print(error)
        }
    }
    
    func saveGenres(_ genres: [MovieGenre]) async {
        do {
            try await dbWriter.write { db in
                try genres.forEach {
                    try $0.insert(db, onConflict: .ignore)
                }
            }
        } catch {
            print(error)
        }
    }
}
