//  SettingsView.swift
//  MIS
//
//  Erstellt für das Setzen und globale Verwalten einer IP-Adresse

import SwiftUI

struct SettingsView: View {
    // MARK: - Internal

    var fullURL: String {
        "http://\(ipAddress):\(port)"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Darstellung")) {
                    Toggle(isOn: $useDesignTwo) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Alternative Ansicht")
                                .font(.body)
                            Text(useDesignTwo ? "Design 2 aktiv" : "Design 1 aktiv")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(.blue)
                }

                Section(header: Text("Server-IP-Adresse")) {
                    TextField("IP-Adresse eingeben", text: $input)
                        .keyboardType(.decimalPad)
                        .autocapitalization(.none)
                        .onChange(of: input) { _, newValue in
                            if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                               !portInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                ipAddress = newValue
                                port = portInput
                            }
                        }
                    TextField("Port eingeben", text: $portInput)
                        .keyboardType(.numberPad)
                        .autocapitalization(.none)
                        .onChange(of: portInput) { _, newValue in
                            if !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                               !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                ipAddress = input
                                port = newValue
                            }
                        }

                    HStack {
                        Text(fullURL)
                            .font(.callout.bold())
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
            }
            .navigationTitle("Einstellungen")
            .onAppear {
                input = ipAddress
                portInput = port
            }
        }
    }

    // MARK: - Private

    @AppStorage("user_ip_address") private var ipAddress: String = ""
    @AppStorage("user_ip_port") private var port: String = ""
    @AppStorage("use_design_two") private var useDesignTwo: Bool = false
    @State private var input: String = ""
    @State private var portInput: String = ""
}
