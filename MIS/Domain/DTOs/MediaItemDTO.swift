//
//  MediaItemDTO.swift
//  MIS
//
//  Created by Emircan Duman on 02.11.25.
//
import Foundation

// MARK: - MediaItemDTO -

struct MediaItemDTO: Identifiable, Sendable, Hashable {
    let id: UUID
    let createDate: Date
    let location: FileLocation
    var dbID: String?
    var title: String
    var desc: String?
    var file: String
    var imageUpdateToken: UUID = UUID()

    var isFileOnLocalStorage: Bool {
        location == .local
    }
}

extension MediaItemDTO {
    init(from model: MediaItem) {
        id = model.uuid
        dbID = model.file.dbID
        createDate = model.createDate
        location = model.file.location
        title = model.title
        desc = model.desc
        file = model.file.file
    }
}
