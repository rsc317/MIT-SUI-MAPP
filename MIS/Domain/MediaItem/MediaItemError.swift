//
//  MediaItemError.swift
//  FahrPro
//
//  Created by Emircan Duman on 28.09.25.
//

import SwiftUI

enum MediaItemError: Error, Identifiable, Equatable {
    var id: String { localizedDescription }

    case repositoryFailure(String)
    case itemNotFound
    case unknown

    var localizedDescription: LocalizedStringKey {
        switch self {
        case .repositoryFailure:
            MediaItemLK.REPOSITORY_FAILURE_ERROR_KEY.localized
        case .itemNotFound:
            MediaItemLK.STUDENT_NOT_FOUND_ERROR_KEY.localized
        case .unknown:
            MediaItemLK.UNKNOWN_ERROR_KEY.localized
        }
    }
}
