//
//  MimeType.swift
//  MIS
//
//  Created by Emircan Duman on 08.11.25.
//

import Foundation

enum MimeType: String {
    case imageJpeg = "image/jpeg"
    case imagePng = "image/png"
    case videoMp4 = "video/mp4"
    case videoMov = "video/quicktime"
    case unknown = "application/octet-stream"

    // MARK: - Internal

    var isImage: Bool {
        switch self {
        case .imageJpeg, .imagePng: true
        default: false
        }
    }

    var isVideo: Bool {
        switch self {
        case .videoMov, .videoMp4: true
        default: false
        }
    }

    static func getExtension(for ext: String) -> String {
        switch ext {
        case "image/jpeg": "jpg"
        case "image/png": "png"
        case "image/heic": "heic"
        case "video/mp4": "mp4"
        case "video/quicktime": "mov"
        default: "bin"
        }
    }

    static func from(string: String) -> MimeType {
        switch string {
        case "jpeg", "jpg": .imageJpeg
        case "png": .imagePng
        case "mp4": .videoMp4
        case "mov": .videoMov
        default: .unknown
        }
    }

    static func from(url: URL) -> MimeType {
        from(string: url.pathExtension.lowercased())
    }
}
