//
//  ContentViewModel.swift
//  Gametrack
//
//  Created by Luis Fariña on 08/07/2020.
//  Copyright © 2020 Luis Fariña. All rights reserved.
//

import Foundation

final class ContentViewModel: ObservableObject {
    
    private let database: AppDatabase
    
    let gamesViewModel: GamesViewModel
    let completedViewModel: CompletedViewModel
    let searchViewModel: SearchViewModel
    let settingsViewModel: SettingsViewModel
    
    init(database: AppDatabase) {
        self.database = database
        gamesViewModel = GamesViewModel(database: database)
        completedViewModel = CompletedViewModel(database: database)
        searchViewModel = SearchViewModel(database: database)
        settingsViewModel = SettingsViewModel(database: database)
    }
    
}
