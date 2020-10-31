//
//  SearchViewModel.swift
//  Gametrack
//
//  Created by Luis Fariña on 08/07/2020.
//  Copyright © 2020 Luis Fariña. All rights reserved.
//

import Foundation

final class SearchViewModel: ObservableObject {
    
    private let database: AppDatabase
    
    init(database: AppDatabase) {
        self.database = database
    }
    
    // MARK: - Actions
    
    /// Add a game from IGDB
    func addGame(_ game: SearchResult) throws {
        var copy = Game(id: nil, gameId: game.id, name: game.name, storyline: game.storyline, summary: game.summary, releaseDate: game.releaseDate, timestamp: game.timestamp, rating: game.rating, coverURLString: game.coverURLString, platforms: game.platforms, company: game.company)
        try database.saveGame(&copy)
    }
    
}
