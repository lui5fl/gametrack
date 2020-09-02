//
//  CompletedViewModel.swift
//  Gametrack
//
//  Created by Luis Fariña on 08/07/2020.
//  Copyright © 2020 Luis Fariña. All rights reserved.
//

import Combine
import Foundation

final class CompletedViewModel: ObservableObject {
    
    enum Ordering {
        case byCompletionDate
    }
    
    @Published var ordering: Ordering = .byCompletionDate
    
    @Published var games: [Game] = []
    
    private let database: AppDatabase
    private var gamesCancellable: AnyCancellable?
    
    init(database: AppDatabase) {
        self.database = database
        gamesCancellable = gamesPublisher(in: database).sink { [weak self] games in
            self?.games = games.filter({ $0.completed == true })
        }
    }
    
    // MARK: - Actions
    
    /// Undo the completion of a game
    func replayGame(id: Int64) throws {
        var game = games.filter({ $0.id == id })[0]
        game.completed = false
        try database.saveGame(&game)
    }
    
    /// Remove a game permanently
    func deleteGame(id: Int64) throws {
        try database.deleteGames(ids: [id])
    }
    
    // MARK: - Private
    
    private func gamesPublisher(in database: AppDatabase) -> AnyPublisher<[Game], Never> {
        $ordering.map { ordering -> AnyPublisher<[Game], Error> in
            switch ordering {
            case .byCompletionDate:
                return database.gamesOrderedByCompletionDate()
            }
        }
        .map { gamesPublisher in
            gamesPublisher.catch { error in
                Just<[Game]>([])
            }
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }

}
