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
         createDate: Date = Date(),
         file: String
    ) {
        self.uuid = uuid
        self.title = title
        self.desc = desc
        self.createDate = createDate
        self.file = MediaFile(file: file)
    }

    // MARK: - Internal

    var uuid: UUID
    var title: String
    var desc: String?
    var createDate: Date
    var file: MediaFile
    
    static func from(dto: MediaItemDTO, in context: ModelContext) -> MediaItem {
        let item = MediaItem(
            title: dto.title,
            desc: dto.desc,
            createDate: dto.createDate,
            file: dto.mediaFile.file
        )
        context.insert(item)
        return item
    }
}
