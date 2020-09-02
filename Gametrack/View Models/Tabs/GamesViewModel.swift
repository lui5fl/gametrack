//
//  GamesViewModel.swift
//  Gametrack
//
//  Created by Luis Fariña on 08/07/2020.
//  Copyright © 2020 Luis Fariña. All rights reserved.
//

import Combine
import Foundation

final class GamesViewModel: ObservableObject {
    
    enum Ordering {
        case byName
    }
    
    @Published var games: [Game] = []
    @Published var ordering: Ordering = .byName
    
    private let database: AppDatabase
    private var gamesCancellable: AnyCancellable?
    
    init(database: AppDatabase) {
        self.database = database
        gamesCancellable = gamesPublisher(in: database).sink { [weak self] games in
            self?.games = games.filter({ $0.completed == false })
        }
    }
    
    // MARK: - Actions
    
    func completeGame(id: Int64) throws {
        var game = games.filter({ $0.id == id })[0]
        game.completed = true
        game.completionDate = Date()
        try database.saveGame(&game)
    }
    
    // MARK: - Private
    
    private func gamesPublisher(in database: AppDatabase) -> AnyPublisher<[Game], Never> {
        $ordering.map { ordering -> AnyPublisher<[Game], Error> in
            switch ordering {
            case .byName:
                return database.gamesOrderedByName()
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
