//
//  ContentView.swift
//  Gametrack
//
//  Created by Luis Fariña on 07/07/2020.
//  Copyright © 2020 Luis Fariña. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        
        TabView {
            
            /// Games Tab: list all added games
            GamesView(viewModel: viewModel.gamesViewModel).tabItem({
                Image(systemName: "gamecontroller")
            })
            
            /// Completed Tab: list all completed games
            CompletedView(viewModel: viewModel.completedViewModel).tabItem({
                Image(systemName: "checkmark")
            })
            
            /// Search Tab: search for a game on IGDB
            SearchView(viewModel: viewModel.searchViewModel).tabItem({
                Image(systemName: "magnifyingglass")
            })
            
            /// Settings Tab
            SettingsView(viewModel: viewModel.settingsViewModel).tabItem({
                Image(systemName: "gear")
            })
            
        }
        .font(.system(size: 20.0, weight: .semibold, design: .default))
        .accentColor(.purple)
        
    }
    
}
