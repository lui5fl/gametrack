//
//  SearchStore.swift
//  Gametrack
//
//  Created by Luis Fariña on 07/07/2020.
//  Copyright © 2020 Luis Fariña. All rights reserved.
//

import Foundation
import IGDB_SWIFT_API

// API Key Preferences List file attributes
let keyFileName = "Key"
let keyFileExtension = "plist"

class SearchStore: SearchService {
    
    // Singleton
    private init() {}
    static let shared = SearchStore()
    
    // Instantiate IGDBWrapper class for making requests to IGDB's REST API
    lazy var iGDB: IGDBWrapper = {
        let credentials = loadCredentials()
        return IGDBWrapper(clientID: credentials.clientId, accessToken: credentials.accessToken)
    }()
    
    // Load IGDB API credentials from the .plist file in which they're stored
    func loadCredentials() -> (clientId: String, accessToken: String) {
        guard let path = Bundle.main.path(forResource: keyFileName, ofType: keyFileExtension) else {
            fatalError("Could not find `\(keyFileName).\(keyFileExtension)` in the bundle")
        }
        
        guard let keys = NSDictionary(contentsOfFile: path) else {
            fatalError("Could not load keys from `\(keyFileName).\(keyFileExtension)`")
        }
        
        guard let clientId = keys["clientId"] as? String else {
            fatalError("Could not load client ID (\"clientId\") from `\(keyFileName).\(keyFileExtension)`")
        }
        
        guard let accessToken = keys["accessToken"] as? String else {
            fatalError("Could not load client secret (\"accessToken\") from `\(keyFileName).\(keyFileExtension)`")
        }
        
        return (clientId: clientId, accessToken: accessToken)
    }
    
    /// Fetch a game with a specific ID
    func fetchGame(id: Int, completion: @escaping (Result<SearchResult, Error>) -> Void) {
        iGDB.apiProtoRequest(endpoint: .GAMES, apicalypseQuery: "fields name, summary, genres.name, storyline, first_release_date, screenshots.image_id, id, popularity, rating, cover.image_id, involved_companies.company.name; where id = \(id);", dataResponse: { (bytes) -> (Void) in
            guard let protoGame = try? Proto_GameResult(serializedData: bytes).games.first else {
                return
            }
            DispatchQueue.main.async {
                completion(.success(SearchResult(game: protoGame)))
            }
        }) { error  in
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
    
    /// Search a game with a specific name
    func searchGame(name: String, completion: @escaping (Result<[SearchResult], Error>) -> Void) {
        iGDB.apiProtoRequest(endpoint: .GAMES, apicalypseQuery: "fields id, name, first_release_date, cover.image_id, involved_companies.company.name, platforms.name; search \"\(name)\"; limit 10;", dataResponse: { bytes in
            guard let gameResults = try? Proto_GameResult(serializedData: bytes) else {
                return
            }
            let games = gameResults.games.map { SearchResult(game: $0) }
            DispatchQueue.main.async {
              completion(.success(games))
            }
        }, errorResponse: { error in
            print(error)
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        })
    }
    
}


fileprivate extension SearchResult {
    
    init(game: Proto_Game, coverSize: ImageSize = .COVER_BIG) {
        let coverURL = imageBuilder(imageID: game.cover.imageID, size: coverSize, imageType: .PNG)
        let company = game.involvedCompanies.first?.company.name ?? ""
        let platforms = game.platforms.map { $0.name }
        let platformsString = platforms.joined(separator: ";")
        self.init(id: Int(game.id),
                  name: game.name,
                  storyline: game.storyline,
                  summary: game.summary,
                  releaseDate: game.firstReleaseDate.date,
                  timestamp: game.firstReleaseDate.seconds,
                  rating: game.rating,
                  coverURLString: coverURL,
                  platforms: platformsString,
                  company: company)
    }
    
}
