//
//  LoadingView.swift
//  Gametrack
//
//  Created by Luis Fariña on 07/07/2020.
//  Copyright © 2020 Luis Fariña. All rights reserved.
//

import SwiftUI
import UIKit

struct LoadingView: UIViewRepresentable {
    
    typealias UIViewType = UIActivityIndicatorView
    
    func makeUIView(context: UIViewRepresentableContext<LoadingView>) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        return activityIndicator
    }
  
    func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<LoadingView>) {
        uiView.startAnimating()
    }
    
}
