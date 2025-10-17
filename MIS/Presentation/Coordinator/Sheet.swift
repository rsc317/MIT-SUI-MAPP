//
//  Sheet.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import Foundation


enum Sheet: Identifiable {
    case addNewItem(MediaItemViewModel)

    var id: String {
        switch self {
        case .addNewItem:
            return "addNewItem"
        }
    }
}
