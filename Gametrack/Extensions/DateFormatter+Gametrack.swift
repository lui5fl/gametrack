//
//  DateFormatter+Gametrack.swift
//  Gametrack
//
//  Created by Luis Fariña on 19/12/2020.
//  Copyright © 2020 Luis Fariña. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    struct shared {
        
        static let dateAndTime: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/YYYY HH:mm"
            return formatter
        }()
        
        static let year: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY"
            return formatter
        }()
        
    }
    
}
