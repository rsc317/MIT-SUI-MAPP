//
//  Settings.swift
//  MIS
//
//  Created by Emircan Duman on 23.11.25.
//

import Foundation

struct Settings: Equatable, Sendable {
    static let `default` = Settings(
        ipAddress: "",
        port: "",
        useDesignTwo: false
    )

    var ipAddress: String
    var port: String
    var useDesignTwo: Bool
}
