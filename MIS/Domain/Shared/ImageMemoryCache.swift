//
//  ImageMemoryCache.swift
//  MIS
//
//  Created by Emircan Duman on 08.11.25.
//

import Foundation

@MainActor final class ImageMemoryCache {
    // MARK: - Internal

    static let shared = ImageMemoryCache()

    func get(for id: String) -> Data? {
        if cache[id] != nil {
            accessOrder[id] = Date()
        }
        return cache[id]
    }

    func set(_ data: Data, for id: String) {
        cache[id] = data
        accessOrder[id] = Date()
        currentSize += data.count

        if currentSize > maxSizeInBytes {
            evictLeastRecentlyUsed()
        }
    }

    func remove(for id: String) {
        if let data = cache[id] {
            currentSize -= data.count
            cache.removeValue(forKey: id)
            accessOrder.removeValue(forKey: id)
        }
    }

    func clear() {
        cache.removeAll()
        accessOrder.removeAll()
        currentSize = 0
    }

    // MARK: - Private

    private var cache = [String: Data]()
    private var accessOrder = [String: Date]()
    private var currentSize: Int = 0

    private let maxSizeInBytes: Int = 30 * 1024 * 1024

    private func evictLeastRecentlyUsed() {
        let sortedKeys = accessOrder.sorted { $0.value < $1.value }.map(\.key)

        let targetSize = Int(Double(maxSizeInBytes) * 0.8)

        for key in sortedKeys {
            guard currentSize > targetSize else { break }

            if let data = cache[key] {
                currentSize -= data.count
                cache.removeValue(forKey: key)
                accessOrder.removeValue(forKey: key)
            }
        }
    }
}
