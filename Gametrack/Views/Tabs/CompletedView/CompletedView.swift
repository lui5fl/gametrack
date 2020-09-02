//
//  CompletedView.swift
//  Gametrack
//
//  Created by Luis Fariña on 07/07/2020.
//  Copyright © 2020 Luis Fariña. All rights reserved.
//

import SwiftUI

struct CompletedView: View {
    
    @ObservedObject var viewModel: CompletedViewModel
    
    var body: some View {
        
        NavigationView {
            
            // List all games that are completed
            if viewModel.games.count > 0 {
                List(viewModel.games) { game in
                    CompletedViewRow(viewModel: self.viewModel, game: game)
                }
                .navigationBarTitle("Completed")
                
            // Display other view instead of a List if there are no completed games
            } else {
                VStack(alignment: .center) {
                    Spacer()
                    Text("You haven't completed any game yet.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .navigationBarTitle("Completed")
            }
            
        }
        
    }
    
}
