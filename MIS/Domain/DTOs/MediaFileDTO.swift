//
//  MediaFileDTO.swift
//  MIS
//
//  Created by Emircan Duman on 21.11.25.
//

import Foundation
import CoreLocation

struct MediaFileDTO: Identifiable, Sendable, Hashable {
    let id: UUID
    let dbID: String?
    let location: FileLocation
    let file: String
    let fileGPSCoordinate: CLLocationCoordinate2D
    
    static func == (lhs: MediaFileDTO, rhs: MediaFileDTO) -> Bool {
        lhs.id == rhs.id &&
        lhs.dbID == rhs.dbID &&
        lhs.location == rhs.location &&
        lhs.file == rhs.file &&
        lhs.fileGPSCoordinate.latitude == rhs.fileGPSCoordinate.latitude &&
        lhs.fileGPSCoordinate.longitude == rhs.fileGPSCoordinate.longitude
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(dbID)
        hasher.combine(location)
        hasher.combine(file)
        hasher.combine(fileGPSCoordinate.latitude)
        hasher.combine(fileGPSCoordinate.longitude)
    }
}
