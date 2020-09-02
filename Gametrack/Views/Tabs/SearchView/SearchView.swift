//
//  SearchView.swift
//  Gametrack
//
//  Created by Luis Fariña on 07/07/2020.
//  Copyright © 2020 Luis Fariña. All rights reserved.
//

import SwiftUI

struct SearchView: View {
    
    @ObservedObject var viewModel: SearchViewModel
    
    @State private var searchText: String = ""
    @ObservedObject var searchList: SearchList = SearchList()
    
    var body: some View {
        
        let searchTextBinding = Binding<String>(get: {
            self.searchText
        }, set: {
            self.searchText = $0
            if !self.searchText.isEmpty {
                self.searchList.reload(name: self.searchText)
            }
        })
        
        return NavigationView {
            VStack {
                
                SearchBar(text: searchTextBinding)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                
                // While a search is going on, show an activity indicator
                if self.searchList.isLoading {
                    Spacer()
                    LoadingView()
                    Spacer()
                    
                // Otherwise, show latest search results
                } else {
                    if !self.searchText.isEmpty {
                        List(searchList.games) { game in
                            SearchViewRow(viewModel: self.viewModel, game: game)
                        }
                    } else {
                        Spacer()
                    }
                }
                
            }
            .navigationBarTitle("Search")
        }.resignKeyboardOnDragGesture()
        
    }
    
}

struct ResignKeyboardOnDragGesture: ViewModifier {
    var gesture = DragGesture().onChanged{ _ in
        UIApplication.shared.endEditing()
    }
    func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

extension View {
    func resignKeyboardOnDragGesture() -> some View {
        return modifier(ResignKeyboardOnDragGesture())
    }
}
