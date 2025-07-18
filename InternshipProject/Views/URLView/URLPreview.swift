//
//  URLPreview.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 17.07.2025.
//

import SwiftUI

import SwiftUI
import LinkPresentation

struct URLPreview: View {
    enum Style {
        case large
        case compact
    }
    let url: URL?
    let style: Style
    
    @State private var metadata: LPLinkMetadata?
    @State private var image: UIImage?
    @State private var isLoading = false

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if metadata != nil {
                switch style {
                case .large:
                    largePreview
                case .compact:
                    compactPreview
                }
            } else if url != nil {
                fallbackPreview
            }
        }
        .onAppear(perform: loadMetadata)
        // Оновлюємо прев'ю, якщо URL змінився
        .onChange(of: url) { _, _ in
            loadMetadata()
        }
    }
    
    @ViewBuilder
    private var largePreview: some View {
        if let metadata = metadata {
            HStack(spacing: 12) {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                }

                VStack(alignment: .leading) {
                    Text(metadata.title ?? "No Title")
                        .font(.headline)
                        .lineLimit(2)
                    Text(url?.host ?? "")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                Spacer()
            }
            .padding(12)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
        }
    }

    @ViewBuilder
    private var compactPreview: some View {
        HStack(spacing: 6) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .cornerRadius(5)
            } else {
                Image(systemName: "globe")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Text(metadata?.title ?? url?.host ?? "Link")
                .font(.callout)
                .lineLimit(1)
                .foregroundColor(.white)
        }
    }
    
    @ViewBuilder
    private var fallbackPreview: some View {
        HStack {
            Image(systemName: "globe")
            Text(url?.host ?? "Invalid URL")
                .font(.callout)
                .foregroundColor(.gray)
        }
    }
    
    private func loadMetadata() {
        guard let url = url, !isLoading else { return }
        
        self.metadata = nil
        self.image = nil
        isLoading = true
        
        Task {
            let loader = MetadataLoader()
            if let loadedMetadata = await loader.loadMetadata(for: url) {
                self.metadata = loadedMetadata
                if let provider = loadedMetadata.imageProvider {
                    self.image = await loadImage(from: provider)
                }
            }
            isLoading = false
        }
    }
    
    private func loadImage(from provider: NSItemProvider) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            provider.loadObject(ofClass: UIImage.self) { image, error in
                continuation.resume(returning: image as? UIImage)
            }
        }
    }
}

