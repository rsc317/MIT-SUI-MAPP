//
//  ImageMemoryCache.swift
//  MIS
//
//  Created by Emircan Duman on 08.11.25.
//

import Foundation

@MainActor
final class ImageMemoryCache {
    // MARK: - Internal

    static let shared = ImageMemoryCache()

    func get(for id: String) -> Data? {
        cache[id]
    }

    func set(_ data: Data, for id: String) {
        cache[id] = data
    }

    func clear() {
        cache.removeAll()
    }

    // MARK: - Private

    private var cache = [String: Data]()
}
