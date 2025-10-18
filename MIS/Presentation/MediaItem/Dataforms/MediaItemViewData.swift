//
//  MediaItemViewData.swift
//  MIS
//
//  Created by Emircan Duman on 18.10.25.
//

import Foundation

struct MediaItemDataForm: Identifiable, Sendable, Hashable, Codable {
    // MARK: - Lifecycle

    init(title: String, desc: String?, src: URL, createDate: Date, type: MediaType) {
        id = UUID()
        self.title = title
        self.desc = desc
        self.src = src
        self.createDate = createDate
        self.type = type
    }

    init(id: UUID, title: String, desc: String?, src: URL, createDate: Date, type: MediaType) {
        self.id = id
        self.title = title
        self.desc = desc
        self.src = src
        self.createDate = createDate
        self.type = type
    }

    // MARK: - Internal

    let id: UUID
    var title: String
    var desc: String?
    var src: URL
    var createDate: Date
    var type: MediaType

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createDate)
    }

    var typeDisplayName: String {
        switch type {
        case .picture: MediaItemLK.TYPE_DISPLAY_NAME_PICTURE.rawValue
        case .video: MediaItemLK.TYPE_DISPLAY_NAME_VIDEO.rawValue
        }
    }
}
