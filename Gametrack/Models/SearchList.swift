//
//  SearchList.swift
//  Gametrack
//
//  Created by Luis Fariña on 07/07/2020.
//  Copyright © 2020 Luis Fariña. All rights reserved.
//

import Foundation

class SearchList: ObservableObject {
    
    @Published var games: [SearchResult] = []
    @Published var isLoading = false
    
    var searchService = SearchStore.shared
    
    func reload(name: String) {
        self.games = []
        self.isLoading = true
        
        searchService.searchGame(name: name) { [weak self]  (result) in
            self?.isLoading = false
            switch result {
            case .success(let games): self?.games = games
            case .failure(let error): print(error.localizedDescription)
            }
        }
    }
    
}
