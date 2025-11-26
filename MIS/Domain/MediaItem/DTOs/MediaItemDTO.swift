//
//  MediaItemDTO.swift
//  MIS
//
//  Created by Emircan Duman on 02.11.25.
//

import CoreLocation
import Foundation

// MARK: - MediaItemDTO -

struct MediaItemDTO: Identifiable, Sendable, Hashable {
    let id: UUID
    let createDate: Date
    let mediaFile: MediaFileDTO
    var title: String
    var desc: String?
    var fileUpdateToken: UUID = UUID()
    var longitude: CLLocationDegrees { mediaFile.fileGPSCoordinate.longitude }
    var latitude: CLLocationDegrees { mediaFile.fileGPSCoordinate.latitude }
}

extension MediaItemDTO {
    init(from model: MediaItem, fileGPSCoordinate: CLLocationCoordinate2D) {
        id = model.uuid
        createDate = model.createDate
        title = model.title
        desc = model.desc
        mediaFile = MediaFileDTO(id: model.uuid, dbID: model.file.dbID, location: model.file.location, file: model.file.file, fileGPSCoordinate: fileGPSCoordinate)
    }
}
