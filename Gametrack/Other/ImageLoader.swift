//
//  ImageLoader.swift
//  Gametrack
//
//  Created by Luis Fariña on 08/07/2020.
//  Copyright © 2020 Luis Fariña. All rights reserved.
//

import Foundation
import SwiftUI

class ImageLoader: ObservableObject {
    
    public static let imageCache = NSCache<AnyObject, AnyObject>()
    
    @Published var isLoading: Bool = true
    @Published var image: UIImage? = nil
    
    public func downloadImage(url: URL) {
        let urlString = url.absoluteString

        // Retrieve image from cache if it exists and display it on the UIImage instance
        if let imageFromCache = ImageLoader.imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = imageFromCache
            return
        }

        // Download image if it's not cached
        URLSession.shared.dataTask(with: url) { (data, res, error) in
            
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            // Save downloaded image in cache and display it on the UIImage instance
            DispatchQueue.main.async { [weak self] in
                ImageLoader.imageCache.setObject(image, forKey: urlString  as AnyObject)
                self?.isLoading = false
                self?.image = image
            }
            
        }.resume()
    }
    
}
