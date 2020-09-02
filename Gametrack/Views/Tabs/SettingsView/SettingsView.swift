//
//  SettingsView.swift
//  Gametrack
//
//  Created by Luis Fariña on 08/07/2020.
//  Copyright © 2020 Luis Fariña. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        
        NavigationView {
            Form {
                Section(header: Text("DANGER ZONE")) {
                    
                    Button(action: viewModel.deleteAllGames) {
                        Text("Delete all games").foregroundColor(.red)
                    }
                    
                    Button(action: viewModel.eraseAllCachedArtwork) {
                        Text("Erase all cached artwork").foregroundColor(.red)
                    }
                    
                }
            }.navigationBarTitle("Settings")
        }
        
    }
    
}
