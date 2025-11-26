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
    // MARK: - Internal

    func loadSettings() -> Settings {
        Settings(
            ipAddress: UserDefaults.standard.string(forKey: Keys.ipAddress) ?? "",
            port: UserDefaults.standard.string(forKey: Keys.port) ?? "",
            useDesignTwo: UserDefaults.standard.bool(forKey: Keys.useDesignTwo)
        )
    }

    func saveSettings(_ settings: Settings) {
        UserDefaults.standard.set(settings.ipAddress, forKey: Keys.ipAddress)
        UserDefaults.standard.set(settings.port, forKey: Keys.port)
        UserDefaults.standard.set(settings.useDesignTwo, forKey: Keys.useDesignTwo)
    }

    func saveDesignPreference(_ useDesignTwo: Bool) {
        UserDefaults.standard.set(useDesignTwo, forKey: Keys.useDesignTwo)
    }

    func clearSettings() {
        UserDefaults.standard.removeObject(forKey: Keys.ipAddress)
        UserDefaults.standard.removeObject(forKey: Keys.port)
        UserDefaults.standard.removeObject(forKey: Keys.useDesignTwo)
    }

    // MARK: - Private

    private enum Keys {
        static let ipAddress = "user_ip_address"
        static let port = "user_ip_port"
        static let useDesignTwo = "use_design_two"
    }
}
