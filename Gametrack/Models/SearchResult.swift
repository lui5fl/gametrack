//
//  SearchResult.swift
//  Gametrack
//
//  Created by Luis Fariña on 09/07/2020.
//  Copyright © 2020 Luis Fariña. All rights reserved.
//

import Foundation

struct SearchResult {
    
    var id: Int
    var name: String
    var storyline: String
    var summary: String
    var releaseDate: Date
    var timestamp: Int64
    var rating: Double
    var coverURLString: String
    var platforms: String
    var company: String
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYYY"
        return formatter
    }()
    
    static let dateFormatterYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY"
        return formatter
    }()
    
    var releaseDateText: String {
        return SearchResult.dateFormatter.string(from: releaseDate)
    }
    
    var releaseYearText: String {
        return SearchResult.dateFormatterYear.string(from: releaseDate)
    }
    
    var coverURL: URL? {
        return URL(string: coverURLString)
    }
    
    var platformsArray: [String] {
        return platforms.components(separatedBy: ";")
    }
    
}

extension SearchResult: Identifiable {}
