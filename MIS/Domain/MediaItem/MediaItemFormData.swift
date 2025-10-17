//
//  MediaItemFormData.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import Foundation

struct MediaItemFormData: Hashable, Identifiable {
    let id: UUID
    var title: String
    var description: String?
    var src: URL
    var createDate: Date
    var type: MediaType

    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        src: URL,
        createDate: Date,
        type: MediaType
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.src = src
        self.createDate = createDate
        self.type = type
    }
}
