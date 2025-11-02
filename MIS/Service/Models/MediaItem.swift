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
final class MediaItem: Identifiable {
    // MARK: - Lifecycle

    init(uuid: UUID = UUID(),
         title: String,
         desc: String? = nil,
         fileSrc: String,
         createDate: Date = Date(),
         type: MediaType = .picture) {
        self.uuid = uuid
        self.title = title
        self.desc = desc
        self.fileSrc = fileSrc
        self.createDate = createDate
        self.type = type
    }

    // MARK: - Internal
    var uuid: UUID
    var title: String
    var desc: String?
    var fileSrc: String
    var createDate: Date
    var type: MediaType

    static func from(dto: MediaItemDTO, in context: ModelContext) -> MediaItem {
        let item = MediaItem(
            title: dto.title,
            desc: dto.desc,
            fileSrc: dto.fileSrc,
            createDate: dto.createDate,
            type: dto.type
        )
        context.insert(item)
        return item
    }
}

// MARK: - MediaType -

enum MediaType: String, Codable {
    case picture
    case video
}
