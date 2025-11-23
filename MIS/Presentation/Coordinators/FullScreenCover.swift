//
//  FullScreenCover.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import Foundation

enum FullScreenCover: Identifiable {
    case itemDetail

    // MARK: - Internal

    var id: String {
        switch self {
        case .itemDetail: "itemDetail"
        }
    }
}
