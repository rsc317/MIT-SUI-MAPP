//
//  MediaItem.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import Foundation
import SwiftData

@Model
final class MediaItem: Identifiable, Sendable {
    var title: String
    var desc: String?
    var src: URL
    var createDate: Date
    var type: MediaType
    
    init(title: String, desc: String? = nil, src: URL, createDate: Date = Date(), type: MediaType = .picture) {
        self.title = title
        self.desc = desc
        self.src = src
        self.createDate = createDate
        self.type = type
    }
}

enum MediaType: String, Codable {
    case picture
    case video
}
