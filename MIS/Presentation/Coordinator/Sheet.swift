//
//  Sheet.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import Foundation

enum Sheet: Identifiable {
    case addNewItem(MediaItemViewModel)

    // MARK: - Internal

    var id: String {
        switch self {
        case .addNewItem:
            "addNewItem"
        }
    }
}
