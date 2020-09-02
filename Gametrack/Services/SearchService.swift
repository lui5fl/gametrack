//
//  SearchService.swift
//  Gametrack
//
//  Created by Luis Fariña on 07/07/2020.
//  Copyright © 2020 Luis Fariña. All rights reserved.
//

import Foundation

protocol SearchService {
    
    /// Fetch a game with a specific ID
    func fetchGame(id: Int, completion: @escaping (Result<SearchResult, Error>) -> Void)
    
    /// Search a game with a specific name
    func searchGame(name: String, completion: @escaping (Result<[SearchResult], Error>) -> Void)
    
}
