//
//  MediaItem.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import Foundation
import SwiftData

// MARK: - MediaItem -

@Model
final class MediaItem: Identifiable, Sendable {
    // MARK: - Lifecycle

    init(uuid: UUID = UUID(),
         title: String,
         desc: String? = nil,
         src: URL,
         createDate: Date = Date(),
         type: MediaType = .picture) {
        self.uuid = uuid
        self.title = title
        self.desc = desc
        self.src = src
        self.createDate = createDate
        self.type = type
    }

    // MARK: - Internal

    @Attribute(.unique) var uuid: UUID

    var title: String
    var desc: String?
    var src: URL
    var createDate: Date
    var type: MediaType
}

// MARK: - MediaType -

enum MediaType: String, Codable {
    case picture
    case video
}
