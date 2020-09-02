//
//  CompletedViewRow.swift
//  Gametrack
//
//  Created by Luis Fariña on 09/07/2020.
//  Copyright © 2020 Luis Fariña. All rights reserved.
//

import SwiftUI

struct CompletedViewRow: View {
    
    @ObservedObject var viewModel: CompletedViewModel
    
    var game: Game
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    
    init(viewModel: CompletedViewModel, game: Game) {
        self.viewModel = viewModel
        self.game = game
        if let url = self.game.coverURL {
            self.imageLoader.downloadImage(url: url)
        }
    }
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 20.0) {
            
            // Cover art
            if (imageLoader.image != nil) {
                Image(uiImage: self.imageLoader.image!)
                    .resizable()
                    .cornerRadius(8)
                    .scaledToFill()
                    .frame(width: 60, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                if (imageLoader.isLoading) {
                    LoadingView()
                        .cornerRadius(8)
                        .scaledToFill()
                        .frame(width: 60, height: 90)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            
            // Info
            VStack(alignment: .leading) {
                
                // Platform
                if game.platformsArray.count > 0 {
                    Text((game.platformsArray.count > 1 ? "Multi-platform" : game.platformsArray[0]).uppercased()).font(.system(size: 13.0))
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 5)
                }
                
                
                // Title
                Text(game.name)
                    .fontWeight(.heavy)
                    .font(.system(size: 19.0))
                    .lineLimit(nil)
                
                // Company
                if !game.company.isEmpty {
                    Text(game.company)
                        .font(.system(size: 15.0))
                        .padding(.top, 5)
                        .lineLimit(nil)
                }
                    
                // Release year
                if !game.releaseYearText.isEmpty && game.timestamp > 0 {
                    Text(game.releaseYearText).font(.system(size: 15.0)).foregroundColor(.secondary)
                    .padding(.top, 5)
                }
                
                // Completion date
                if game.completed {
                    HStack(alignment: .center, spacing: 5) {
                        Image(systemName: "checkmark.circle.fill").font(.system(size: 13.0)).foregroundColor(.green)
                        Text(game.completionDateText).font(.system(size: 15.0)).foregroundColor(.green)
                    }
                    .padding(.top, 5)
                }
                
            }
            
            Spacer()
            Divider()
            
            // "Undo" and "Delete" buttons
            VStack {
                Spacer()
                Image(systemName: "xmark")
                    .font(.system(size: 20.0, weight: .semibold, design: .default))
                    .foregroundColor(.secondary)
                    .onTapGesture {
                        try! self.viewModel.replayGame(id: self.game.id!)
                    }
                Spacer()
                Image(systemName: "trash")
                    .font(.system(size: 20.0, weight: .semibold, design: .default))
                    .foregroundColor(.secondary)
                    .onTapGesture {
                        try! self.viewModel.deleteGame(id: self.game.id!)
                    }
                Spacer()
            }
            .padding(.trailing, 5.0)
            
        }
        .padding(.vertical, 10)
        
    }
    
}
