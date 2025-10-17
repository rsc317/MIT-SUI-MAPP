//
//  LocalizationKeyProtocol+Protocol.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import SwiftUI

protocol LocalizationKeyProtocol {
    var rawValue: String { get }
    var string: String { get }
    var localized: LocalizedStringKey { get }
}

extension LocalizationKeyProtocol {
    var string: String {
        NSLocalizedString(rawValue, comment: "")
    }
    var localized: LocalizedStringKey {
        LocalizedStringKey(rawValue)
    }
}
