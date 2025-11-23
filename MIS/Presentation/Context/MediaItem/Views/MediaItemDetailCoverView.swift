//
//  MediaItemDetailCoverView.swift
//  MIS
//
//  Created by Emircan Duman on 22.11.25.
//

import SwiftUI

struct MediaItemDetailCoverView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: MediaItemViewModel

    @State private var showDeleteAlert: Bool = false
    @State private var image = Image(systemName: "photo")
    @State private var isLoading = true
    @State private var scale: CGFloat = 1.0
    @State private var offset = CGSize.zero
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.primary)
                            .symbolRenderingMode(.hierarchical)
                    }

                    Spacer()
                    
                    Text(viewModel.currentItem?.title ?? "")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.text)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
                    Spacer()

                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.red)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 24) {
                        if isLoading {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 400)
                                .overlay {
                                    ProgressView()
                                        .scaleEffect(1.5)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .scaleEffect(scale)
                                .offset(offset)
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            scale = lastScale * value
                                        }
                                        .onEnded { _ in
                                            lastScale = scale
                                            if scale < 1.0 {
                                                withAnimation(.spring()) {
                                                    scale = 1.0
                                                    lastScale = 1.0
                                                    offset = .zero
                                                }
                                            }
                                        }
                                )
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            if scale > 1.0 {
                                                offset = value.translation
                                            }
                                        }
                                        .onEnded { _ in
                                            if scale <= 1.0 {
                                                withAnimation(.spring()) {
                                                    offset = .zero
                                                }
                                            }
                                        }
                                )
                                .onTapGesture(count: 2) {
                                    withAnimation(.spring()) {
                                        if scale > 1.0 {
                                            scale = 1.0
                                            lastScale = 1.0
                                            offset = .zero
                                        } else {
                                            scale = 2.0
                                            lastScale = 2.0
                                        }
                                    }
                                }
                        }

                        // Info Card
                        VStack(alignment: .leading, spacing: 20) {
                            // Datum
                            HStack(alignment: .center, spacing: 12) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.blue)
                                    .frame(width: 28, alignment: .center)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Erstellt am")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    if let date = viewModel.currentItem?.createDate {
                                        Text(date.formatted(date: .long, time: .shortened))
                                            .font(.body)
                                            .foregroundStyle(.text)
                                    }
                                }

                                Spacer()
                            }

                            HStack(alignment: .center, spacing: 12) {
                                Image(systemName: "globe")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.blue)
                                    .frame(width: 28, alignment: .center)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("GPS Koordinaten")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    if let item = viewModel.currentItem {
                                        Text(String(format: "%.6f, %.6f", item.latitude, item.longitude))
                                            .font(.body)
                                            .foregroundStyle(.text)
                                    }
                                }

                                Spacer()
                            }

                            // Speicherort
                            HStack(alignment: .center, spacing: 12) {
                                Image(systemName: viewModel.currentItem?.mediaFile.location == .local ? "internaldrive.fill" : "cloud.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(viewModel.currentItem?.mediaFile.location == .local ? .green : .blue)
                                    .frame(width: 28, alignment: .center)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Speicherort")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(viewModel.currentItem?.mediaFile.location == .local ? "Lokal gespeichert" : "Extern gespeichert")
                                        .font(.body)
                                        .foregroundStyle(.text)
                                }

                                Spacer()
                            }

                            if let desc = viewModel.currentItem?.desc, !desc.isEmpty {
                                Divider()
                                    .background(Color.secondary.opacity(0.3))

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Beschreibung")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                        .textCase(.uppercase)

                                    Text(desc)
                                        .font(.body)
                                        .foregroundStyle(.text)
                                        .lineSpacing(4)
                                }
                            }
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.card)
                                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .task {
            await loadImage()
        }
        .deleteConfirmationAlert(
            isPresented: $showDeleteAlert,
            title: "Medium löschen?",
            message: "Möchten Sie das Medium \(viewModel.currentItemTitle) wirklich löschen?",
            destructiveAction: {
                Task {
                    await viewModel.deleteCurrentItem()
                    dismiss()
                }
            }
        )
        .onDisappear {
            viewModel.onDisappearAction()
        }
    }

    @MainActor private func loadImage() async {
        defer { isLoading = false }

        if let data = try? await viewModel.getImageData(),
           let uiImage = UIImage(data: data) {
            image = Image(uiImage: uiImage)
        }
    }
}
