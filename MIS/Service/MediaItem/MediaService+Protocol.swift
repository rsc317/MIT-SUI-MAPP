//
//  MediaService+Protocol.swift
//  MIS
//
//  Created by Emircan Duman on 08.11.25.
//
import Foundation

protocol MediaServiceProtocol {
    func updateMedia(mediaID: Int, fileData: Data, fileURL: URL) async throws
    func uploadMedia(data: Data, fileURL: URL) async throws -> Int
    func fetchMetadata(for id: Int) async throws -> [String: Any]
    func downloadMedia(id: Int) async throws -> Data
}
