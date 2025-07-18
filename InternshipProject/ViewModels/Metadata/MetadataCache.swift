//
//  MetadataCache.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 17.07.2025.
//

import Foundation
import LinkPresentation


class MetadataCacheManager {
    static let shared = MetadataCacheManager()
    
    private let cache = NSCache<NSString, LPLinkMetadata>()

    private init() {}

    func get(for url: URL) -> LPLinkMetadata? {
        return cache.object(forKey: url.absoluteString as NSString)
    }

    // берегти метадані в кеш
    func set(_ metadata: LPLinkMetadata, for url: URL) {
        cache.setObject(metadata, forKey: url.absoluteString as NSString)
    }
}
