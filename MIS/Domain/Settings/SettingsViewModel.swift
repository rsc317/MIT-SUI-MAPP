//
//  SettingsViewModel.swift
//  MIS
//
//  Created on 23.11.25.
//

import Combine
import Foundation
import Observation
import SwiftUI

//@MainActor
@Observable final class SettingsViewModel {
    // MARK: - Lifecycle

    init(_ repository: SettingsRepositoryProtocol) {
        self.repository = repository
        loadSettings()
    }

    // MARK: - Internal

    var ipAddressError: String?
    var portError: String?

    var ipAddressInput: String = "" {
        didSet {
            validateAndSaveIfNeeded()
        }
    }

    var portInput: String = "" {
        didSet {
            validateAndSaveIfNeeded()
        }
    }

    var useDesignTwo: Bool = false {
        didSet {
            repository.saveDesignPreference(useDesignTwo)
        }
    }

    var fullURL: String {
        let ip = ipAddressInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let portStr = portInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !ip.isEmpty, !portStr.isEmpty else {
            return "http://nicht-konfiguriert"
        }

        return "http://\(ip):\(portStr)"
    }

    var isValid: Bool {
        let ipTrimmed = ipAddressInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let portTrimmed = portInput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Felder müssen ausgefüllt sein UND keine Fehler haben
        return !ipTrimmed.isEmpty 
            && !portTrimmed.isEmpty 
            && ipAddressError == nil 
            && portError == nil
            && isValidIPFormat(ipTrimmed)
            && isValidPortFormat(portTrimmed)
    }
    
    private func isValidIPFormat(_ ip: String) -> Bool {
        let components = ip.split(separator: ".")
        guard components.count == 4 else { return false }
        
        for component in components {
            guard let num = Int(component), num >= 0, num <= 255 else {
                return false
            }
        }
        return true
    }
    
    private func isValidPortFormat(_ port: String) -> Bool {
        guard let portNum = Int(port), portNum > 0, portNum <= 65535 else {
            return false
        }
        return true
    }

    func loadSettings() {
        let settings = repository.loadSettings()
        ipAddressInput = settings.ipAddress
        portInput = settings.port
        useDesignTwo = settings.useDesignTwo
    }

    func validateIPAddress() -> Bool {
        let trimmed = ipAddressInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            ipAddressError = "IP-Adresse darf nicht leer sein"
            return false
        }

        let components = trimmed.split(separator: ".")
        guard components.count == 4 else {
            ipAddressError = "Ungültiges IP-Format (erwarte xxx.xxx.xxx.xxx)"
            return false
        }

        for component in components {
            guard let num = Int(component), num >= 0, num <= 255 else {
                ipAddressError = "Jeder Teil muss zwischen 0 und 255 liegen"
                return false
            }
        }

        ipAddressError = nil
        return true
    }

    func validatePort() -> Bool {
        let trimmed = portInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            portError = "Port darf nicht leer sein"
            return false
        }
        guard let portNum = Int(trimmed), portNum > 0, portNum <= 65535 else {
            portError = "Port muss zwischen 1 und 65535 liegen"
            return false
        }

        portError = nil
        return true
    }

    func saveSettings() {
        guard validateIPAddress(), validatePort() else { return }

        let settings = Settings(
            ipAddress: ipAddressInput.trimmingCharacters(in: .whitespacesAndNewlines),
            port: portInput.trimmingCharacters(in: .whitespacesAndNewlines),
            useDesignTwo: useDesignTwo
        )

        repository.saveSettings(settings)
    }

    func resetToDefaults() {
        ipAddressInput = ""
        portInput = ""
        useDesignTwo = false
        ipAddressError = nil
        portError = nil
        repository.clearSettings()
    }

    // MARK: - Private

    private let repository: SettingsRepositoryProtocol

    private func validateAndSaveIfNeeded() {
        let ipTrimmed = ipAddressInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let portTrimmed = portInput.trimmingCharacters(in: .whitespacesAndNewlines)

        if !ipTrimmed.isEmpty {
            ipAddressError = nil
        }

        if !portTrimmed.isEmpty {
            portError = nil
        }

        if !ipTrimmed.isEmpty, !portTrimmed.isEmpty {
            saveSettings()
        }
    }
}
