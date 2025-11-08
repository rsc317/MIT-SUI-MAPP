//
//  MediaFile.swift
//  MIS
//
//  Created by Emircan Duman on 08.11.25.
//

import SwiftData
import Foundation

@Model
final class MediaFile: Identifiable {
    // MARK: - Lifecycle

    init(_ dbID: String? = nil, _ file: String) {
        self.dbID = dbID
        self.file = file
    }

    // MARK: - Internal

    var dbID: String?
    var file: String

    var url: URL { URL(filePath: file) }
    var name: String { url.deletingPathExtension().lastPathComponent }
    var exten: String { url.lastPathComponent }
    var type: MimeType { MimeType.from(url: url) }
    var location: FileLocation {
        guard let dbID = dbID, !dbID.isEmpty else { return .local }
        return .remote
    }
}
