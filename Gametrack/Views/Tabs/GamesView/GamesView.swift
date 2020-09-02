//
//  GamesView.swift
//  Gametrack
//
//  Created by Luis Fariña on 07/07/2020.
//  Copyright © 2020 Luis Fariña. All rights reserved.
//

import SwiftUI

struct GamesView: View {
    
    @ObservedObject var viewModel: GamesViewModel
    
    var body: some View {
        
        NavigationView {
            
            // List all games that are not completed
            if viewModel.games.count > 0 {
                List(viewModel.games) { game in
                    GamesViewRow(viewModel: self.viewModel, game: game)
                }
                .navigationBarTitle("Games")
            
            // Display other view instead of a List if there are no games to show
            } else {
                VStack(alignment: .center) {
                    Spacer()
                    Text("Go to the Search tab to add any games you're currently playing!")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .navigationBarTitle("Games")
            }
            
        }
        
    }
    
}
