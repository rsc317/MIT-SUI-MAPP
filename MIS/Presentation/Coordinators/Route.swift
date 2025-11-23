//
//  Route.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import Foundation

// MARK: - MediaItemRoute

enum MediaItemRoute: Hashable {
    case list
    case detail
}

// MARK: - MapRoute

enum MapRoute: Hashable {
    case map
    case detail
}

// MARK: - SettingsRoute

enum SettingsRoute: Hashable {
    case main
}
