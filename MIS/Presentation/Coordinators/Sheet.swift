//
//  Sheet.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import Foundation

enum Sheet: Identifiable {
    case addOrEditNewItem

    // MARK: - Internal

    var id: String {
        switch self {
        case .addOrEditNewItem:
            "addOrEditNewItem"
        }
    }
}
