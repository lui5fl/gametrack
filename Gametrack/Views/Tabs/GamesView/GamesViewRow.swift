//
//  GamesViewRow.swift
//  Gametrack
//
//  Created by Luis Fariña on 08/07/2020.
//  Copyright © 2020 Luis Fariña. All rights reserved.
//

import SwiftUI

struct GamesViewRow: View {
    
    @ObservedObject var viewModel: GamesViewModel
    
    var game: Game
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    
    init(viewModel: GamesViewModel, game: Game) {
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
                
            }
            
            Spacer()
            Divider()
            
            // "Complete" button
            VStack {
                Spacer()
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 20.0, weight: .semibold, design: .default))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.trailing, 5.0)
            .onTapGesture {
                try! self.viewModel.completeGame(id: self.game.id!)
            }
            
        }
        .padding(.vertical, 10)
        
    }
    
}
