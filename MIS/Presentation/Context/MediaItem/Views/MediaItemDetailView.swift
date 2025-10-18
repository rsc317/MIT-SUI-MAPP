//
//  MediaItemDetailView.swift
//  MediaApp
//
//  Created by OpenAI on 2025-10-17.
//

import SwiftUI

struct MediaItemDetailView: View {
    let formData: MediaItemDataForm

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.background.opacity(0.15))
                    .frame(width: 120, height: 120)
                    .overlay {
                        Image(systemName: formData.typeDisplayName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(.text)
                    }

                Text(formData.title)
                    .font(.title)
                    .bold()
                    .foregroundStyle(.text)

                Text(formData.type.rawValue.capitalized)
                    .font(.headline)
                    .foregroundStyle(.text)

                Text(formData.createDate, format: .dateTime)
                    .foregroundStyle(.text)

                if let desc = formData.desc, !desc.isEmpty {
                    Text(desc)
                        .foregroundStyle(.text)
                        .multilineTextAlignment(.leading)
                } else {
                    Text(LocalizedStringKey("No description"))
                        .italic()
                        .foregroundStyle(.text.opacity(0.6))
                }
            }
            .padding()
        }
        .navigationTitle(formData.title)
        .toolbarTitleDisplayMode(.inline)
        .modifier(NavigationBarTitleColorModifier(color: .accent))
    }
}
