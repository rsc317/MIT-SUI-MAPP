//
//  SettingsRepository+Protocol.swift
//  MIS
//
//  Created by Emircan Duman on 23.11.25.
//

protocol SettingsRepositoryProtocol {
    func loadSettings() -> Settings
    func saveSettings(_ settings: Settings)
    func saveDesignPreference(_ useDesignTwo: Bool)
    func clearSettings()
}
