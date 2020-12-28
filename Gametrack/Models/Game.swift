//
//  Game.swift
//  Gametrack
//
//  Created by Luis Fariña on 07/07/2020.
//  Copyright © 2020 Luis Fariña. All rights reserved.
//

import Foundation
import GRDB

struct Game: Identifiable {
    
    // MARK: Properties
    
    var id: Int64?
    var gameId: Int
    var name: String
    var storyline: String
    var summary: String
    var releaseDate: Date
    var timestamp: Int64
    var rating: Double
    var coverURLString: String
    var platforms: String
    var company: String
    var completed: Bool = false
    var completionDate: Date = Date()
    
    // MARK: Computed properties
    
    var releaseDateText: String {
        DateFormatter.shared.dateAndTime.string(from: releaseDate)
    }
    
    var releaseYearText: String {
        DateFormatter.shared.year.string(from: releaseDate)
    }
    
    var coverURL: URL? {
        URL(string: coverURLString)
    }
    
    var platformsArray: [String] {
        platforms.components(separatedBy: ";")
    }
    
    var completionDateText: String {
        DateFormatter.shared.dateAndTime.string(from: completionDate)
    }
    
}

// MARK: - Game

extension Game: Codable, FetchableRecord, MutablePersistableRecord {

    fileprivate enum Columns {
        static let name = Column(CodingKeys.name)
        static let completionDate = Column(CodingKeys.completionDate)
    }
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
    
}

// MARK: - DerivableRequest

extension DerivableRequest where RowDecoder == Game {
    
    func orderedByName() -> Self {
        order(Game.Columns.name)
    }

    func orderedByCompletionDate() -> Self {
        order(Game.Columns.completionDate).reversed()
    }
    
}
