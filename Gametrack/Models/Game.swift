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
    
    var id: Int64?
    var gameId: Int
    var name: String
    var storyline: String
    var summary: String
    var releaseDate: Date
    var timestamp: Int64
    var popularity: Double
    var rating: Double
    var coverURLString: String
    var platforms: String
    var company: String
    var completed: Bool = false
    var completionDate: Date = Date()
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYYY HH:mm"
        return formatter
    }()
    
    static let dateFormatterYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY"
        return formatter
    }()
    
    var releaseDateText: String {
        return Game.dateFormatter.string(from: releaseDate)
    }
    
    var releaseYearText: String {
        return Game.dateFormatterYear.string(from: releaseDate)
    }
    
    var coverURL: URL? {
        return URL(string: coverURLString)
    }
    
    var platformsArray: [String] {
        return platforms.components(separatedBy: ";")
    }
    
    var completionDateText: String {
        return Game.dateFormatter.string(from: completionDate)
    }
    
}

extension Game: Codable, FetchableRecord, MutablePersistableRecord {

    fileprivate enum Columns {
        static let name = Column(CodingKeys.name)
        static let company = Column(CodingKeys.company)
        static let completionDate = Column(CodingKeys.completionDate)
    }
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
    
}

extension DerivableRequest where RowDecoder == Game {
    
    func orderedByName() -> Self {
        order(Game.Columns.name)
    }

    func orderedByCompletionDate() -> Self {
        order(Game.Columns.completionDate).reversed()
    }
    
}
