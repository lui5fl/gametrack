//
//  SettingsViewModel.swift
//  Gametrack
//
//  Created by Luis Fariña on 08/07/2020.
//  Copyright © 2020 Luis Fariña. All rights reserved.
//

import Foundation

final class SettingsViewModel: ObservableObject {
    
    private let database: AppDatabase
    
    init(database: AppDatabase) {
        self.database = database
    }
    
    func deleteAllGames() {
        try! database.deleteAllGames()
    }
    
    func eraseAllCachedArtwork() {
        ImageLoader.imageCache.removeAllObjects()
    }
    
}
