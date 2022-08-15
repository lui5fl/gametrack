//
//  Text+Gametrack.swift
//  Gametrack
//
//  Created by Luis Fariña on 28/12/2020.
//  Copyright © 2020 Luis Fariña. All rights reserved.
//

import SwiftUI

extension Text {
    
    static func optional(_ content: String?) -> Text? {
        guard let content = content else {
            return nil
        }
        return Text(content)
    }
    
}
