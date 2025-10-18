//
//  UIComponentFactory+Section.swift
//  MIS
//
//  Created by Emircan Duman on 18.10.25.
//

import SwiftUI

extension UIComponentFactory {
    static func createSection(
        label: LocalizationKeyProtocol,
        accessibilityId: AccessibilityIdentifierProtocol,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.localized)
                .font(.title)
                .foregroundStyle(.accent)
            VStack(alignment: .leading, spacing: 8) {
                content()
            }
            .padding()
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.accent, lineWidth: 1)
                    .allowsHitTesting(false)
            )
        }
        .accessibilityIdentifier(accessibilityId.rawValue)
    }
}
