//
//  Database+Migrator.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation
import GRDB

extension Database {
    var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
#if DEBUG
        // Speed up development by nuking the database when migrations change
        // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/migrations>
        migrator.eraseDatabaseOnSchemaChange = true
#endif
        
        migrator.registerMigration("createPlayer", foreignKeyChecks: .immediate) { db in
            // Create a table
            // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseschema>
            try db.create(table: "movie") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("title", .text).notNull()
                t.column("imageURL", .text)
                t.column("overview", .text)
            }
            
            try db.create(table: "genre", body: { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull()
            })
            
            try db.create(table: "person", body: { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text).notNull()
                t.column("imageURL", .text)
            })
            
            try db.create(table: "personMovie", body: { t in
                t.column("personId", .integer)
                    .indexed()
                    .references("person", onDelete: .cascade)
                t.column("movieId", .integer)
                    .indexed()
                    .references("movie", onDelete: .cascade)
            })
            
            try db.create(table: "movieGenre", body: { t in
                t.column("genreId", .integer)
                    .indexed()
                    .references("genre", onDelete: .cascade)
                t.column("movieId", .integer)
                    .indexed()
                    .references("movie", onDelete: .cascade)
            })
        }
        
        // Migrations for future application versions will be inserted here:
        // migrator.registerMigration(...) { db in
        //     ...
        // }
        
        return migrator
    }
}
