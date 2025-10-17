//
//  FullScreenCover.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import Foundation


enum FullScreenCover: String, Identifiable {
    var id: String {
        self.rawValue
    }
    
    case editItem
}
