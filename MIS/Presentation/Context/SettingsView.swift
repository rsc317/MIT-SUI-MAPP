//  SettingsView.swift
//  MIS
//
//  Erstellt für das Setzen und globale Verwalten einer IP-Adresse

import SwiftUI

struct SettingsView: View {
    // MARK: - Internal

    @State var viewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Darstellung")) {
                    Toggle(isOn: $viewModel.useDesignTwo) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Alternative Ansicht")
                                .font(.body)
                            Text(viewModel.useDesignTwo ? "Design 2 aktiv" : "Design 1 aktiv")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(.blue)
                }

                Section(header: Text("Server-Konfiguration")) {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("IP-Adresse eingeben", text: $viewModel.ipAddressInput)
                            .keyboardType(.decimalPad)
                            .autocapitalization(.none)
                            .textFieldStyle(.roundedBorder)
                        
                        if let ipError = viewModel.ipAddressError {
                            Text(ipError)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Port eingeben", text: $viewModel.portInput)
                            .keyboardType(.numberPad)
                            .autocapitalization(.none)
                            .textFieldStyle(.roundedBorder)
                        
                        if let portError = viewModel.portError {
                            Text(portError)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Vollständige URL")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text(viewModel.fullURL)
                                .font(.callout.bold())
                                .foregroundColor(viewModel.isValid ? .primary : .secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            
                            Spacer()
                            
                            if viewModel.isValid {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                
                Section {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Einstellungen zurücksetzen")
                        }
                    }
                }
            }
            .navigationTitle("Einstellungen")
            .alert("Einstellungen zurücksetzen?", isPresented: $showResetAlert) {
                Button("Abbrechen", role: .cancel) {}
                Button("Zurücksetzen", role: .destructive) {
                    viewModel.resetToDefaults()
                }
            } message: {
                Text("Möchten Sie wirklich alle Einstellungen auf die Standardwerte zurücksetzen?")
            }
        }
    }

    // MARK: - Private

    @State private var showResetAlert = false
}
