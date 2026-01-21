//
//  SettingsRepository.swift
//  MIS
//
//  Created on 23.11.25.
//

import Foundation
import SwiftUI

// MARK: - Settings -

// MARK: - SettingsRepository -

final class SettingsRepository: SettingsRepositoryProtocol {
    func loadSettings() -> Settings {
        Settings(
            ipAddress: UserDefaults.standard.string(forKey: UserDefaultKeys.ipAddress) ?? "",
            port: UserDefaults.standard.string(forKey: UserDefaultKeys.port) ?? "",
            useDesignTwo: UserDefaults.standard.bool(forKey: UserDefaultKeys.useDesignTwo)
        )
    }

    func saveSettings(_ settings: Settings) {
        UserDefaults.standard.set(settings.ipAddress, forKey: UserDefaultKeys.ipAddress)
        UserDefaults.standard.set(settings.port, forKey: UserDefaultKeys.port)
        UserDefaults.standard.set(settings.useDesignTwo, forKey: UserDefaultKeys.useDesignTwo)
    }

    func saveDesignPreference(_ useDesignTwo: Bool) {
        UserDefaults.standard.set(useDesignTwo, forKey: UserDefaultKeys.useDesignTwo)
    }

    func clearSettings() {
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.ipAddress)
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.port)
        UserDefaults.standard.removeObject(forKey: UserDefaultKeys.useDesignTwo)
    }
}
