//
//  AppDatabase.swift
//  Gametrack
//
//  Created by Luis Fariña on 08/07/2020.
//  Copyright © 2020 Luis Fariña. All rights reserved.
//

import Combine
import GRDB

final class AppDatabase {
    
    private let dbQueue: DatabaseQueue
    
    init(_ dbQueue: DatabaseQueue) throws {
        self.dbQueue = dbQueue
        try migrator.migrate(dbQueue)
    }
    
    private var migrator: DatabaseMigrator {
        
        var migrator = DatabaseMigrator()
        
        #if DEBUG
        // https://github.com/groue/GRDB.swift/blob/master/Documentation/Migrations.md#the-erasedatabaseonschemachange-option
        migrator.eraseDatabaseOnSchemaChange = true
        #endif

        // Create Game model
        migrator.registerMigration("createGame") { db in

            try db.create(table: "game") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("gameId", .integer).notNull().unique()
                t.column("name", .text).notNull().collate(.localizedCaseInsensitiveCompare)
                t.column("storyline", .text)
                t.column("summary", .text)
                t.column("releaseDate", .date)
                t.column("timestamp", .integer)
                t.column("rating", .double)
                t.column("coverURLString", .text)
                t.column("platforms", .text)
                t.column("company", .text)
                t.column("completed", .boolean)
                t.column("completionDate", .date)
            }
            
        }
        
        return migrator
        
    }
    
}

// MARK: - Database Access

extension AppDatabase {
    
    // MARK: Writes
    
    /// Save (insert or update) a game
    func saveGame(_ game: inout Game) throws {
        try dbQueue.write { db in
            try game.save(db)
        }
    }
    
    /// Delete certain games
    func deleteGames(ids: [Int64]) throws {
        try dbQueue.write { db in
            _ = try Game.deleteAll(db, keys: ids)
        }
    }
    
    /// Delete all games
    func deleteAllGames() throws {
        try dbQueue.write { db in
            _ = try Game.deleteAll(db)
        }
    }
    
    // MARK: Reads
    
    /// Return all games ordered by name
    func gamesOrderedByName() -> AnyPublisher<[Game], Error> {
        ValueObservation
            .tracking(Game.all().orderedByName().fetchAll)
            .publisher(in: dbQueue, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    /// Return all games ordered by completion date
    func gamesOrderedByCompletionDate() -> AnyPublisher<[Game], Error> {
        ValueObservation
            .tracking(Game.all().orderedByCompletionDate().fetchAll)
            .publisher(in: dbQueue, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
}
