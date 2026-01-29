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
//        try! fileManager.removeItem(at: dbURL)
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
    
    func allPeople() async -> [Person] {
        try! await dbWriter.read { db in
            return try Person.fetchAll(db)
        }
    }
    
    func movie(with id: Int) async -> MovieWithGenres? {
        return try! await dbWriter.read { db in
            let request = Movie.filter(Column("id") == id).including(all: Movie.genres)
            return try MovieWithGenres.fetchOne(db, request)
        }
    }
    
    func allMovies() async -> [MovieWithGenres] {
        return try! await dbWriter.read { db in
            let request = Movie.including(all: Movie.genres)
            return try MovieWithGenres.fetchAll(db, request)
        }
        
    }
    
    func allGenres() async -> [Genre] {
        try! await dbWriter.read { db in
            return try Genre.fetchAll(db)
        }
    }
    
    private func creditsForMovie(_ movie: Movie, db: GRDB.Database) throws -> CreditedMovie {
        let request = Movie
            .including(all: Movie.genres)
            .including(all: Movie.people)
            .filter(Column("id") == movie.id)
        return try CreditedMovie.fetchOne(db, request)!
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
    
    func allCreditedMovies(excludingTitles excludedTitles: [String] = [], includeHidden: Bool = true) async -> [CreditedMovie] {
        do {
            return try await dbWriter.write { db in
                let hiddenAlias = TableAlias()
                let request = Movie.joining(optional: Movie.hidden.aliased(hiddenAlias))
                    .including(all: Movie.genres)
                    .including(all: Movie.people)
                    .filter(!hiddenAlias.exists)
                    .filter(!excludedTitles.contains(Column(("title"))))
                return try CreditedMovie.fetchAll(db, request)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func createPerson(_ person: Person, with movies: [MovieWithGenres]) async {
        try! await dbWriter.write { db in
            try person.insert(db, onConflict: .ignore)
            try movies.forEach { movie in
                try movie.movie.insert(db, onConflict: .ignore)
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
                try movie.delete(db)
                try MovieGenre.filter(Column("movieId") == movie.id).deleteAll(db)
                try PersonMovie.filter(Column("movieId") == movie.id).deleteAll(db)
            }
        } catch {
            print(error)
        }
    }
    
    private func deleteMoviesWithoutPeople() async {
        let movies = await allCreditedMovies().filter { $0.people.count == 0 }
        
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
