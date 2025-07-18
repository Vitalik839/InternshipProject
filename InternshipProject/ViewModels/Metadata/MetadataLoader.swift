//
//  MetadataLoader.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 17.07.2025.
//

import LinkPresentation
import Foundation

@MainActor
class MetadataLoader: ObservableObject {
    private let cache = MetadataCacheManager.shared

    func loadMetadata(for url: URL) async -> LPLinkMetadata? {
        if let cachedMetadata = cache.get(for: url) {
            return cachedMetadata
        }

        // в кеші немає - завантажуємо з мережі
        let provider = LPMetadataProvider()
        do {
            let metadata = try await provider.startFetchingMetadata(for: url)
            cache.set(metadata, for: url)
            return metadata
        } catch {
            print("Failed to fetch metadata for \(url): \(error)")
            return nil
        }
    }
}
