//
//  MediaItemDTO.swift
//  MIS
//
//  Created by Emircan Duman on 02.11.25.
//
import Foundation

struct MediaItemDTO: Identifiable, Sendable, Hashable {
    var id: UUID
    var title: String
    var desc: String?
    var fileSrc: String
    var createDate: Date
    var type: MediaType
    var saveDestination: SaveDestination
}

extension MediaItemDTO {
    init(from model: MediaItem) {
        self.id = model.uuid
        self.title = model.title
        self.desc = model.desc
        self.fileSrc = model.fileSrc
        self.createDate = model.createDate
        self.type = model.type
        self.saveDestination = model.saveDestination
    }
}
