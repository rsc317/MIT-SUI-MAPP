//
//  MediaItemError.swift
//  FahrPro
//
//  Created by Emircan Duman on 28.09.25.
//

import SwiftUI

enum MediaItemError: Error, Identifiable, Equatable {
    case repositoryFailure(String)
    case itemNotFound
    case unknown

    // MARK: - Internal

    var id: String { localizedDescription }

    var localizedDescription: LocalizedStringKey {
        switch self {
        case .repositoryFailure:
            MediaItemLK.REPOSITORY_FAILURE_ERROR_KEY.localized
        case .itemNotFound:
            MediaItemLK.ITEM_NOT_FOUND.localized
        case .unknown:
            MediaItemLK.UNKNOWN_ERROR_KEY.localized
        }
    }
}
