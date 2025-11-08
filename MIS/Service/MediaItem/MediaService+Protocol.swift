//
//  MediaService+Protocol.swift
//  MIS
//
//  Created by Emircan Duman on 08.11.25.
//
import Foundation

protocol MediaServiceProtocol {
    func updateMedia(mediaID: Int, fileData: Data, filename: String, mimeType: String) async throws
    func uploadMedia(fileURL: URL) async throws -> Int
    func fetchMetadata(for id: Int) async throws -> [String: Any]
    func downloadMedia(id: Int) async throws -> Data
}
