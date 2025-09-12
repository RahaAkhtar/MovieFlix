//
//  RemoteImageView.swift
//  MovieFlix
//
//  Created by Muhammad Akhtar on 10/09/2025.
//


import SwiftUI
import Combine
import UIKit

public struct RemoteImageView: View {
    @StateObject private var loader: ImageLoader

    public init(url: URL?) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
    }

    public var body: some View {
        content
            .onAppear { loader.load() }
            .onDisappear { loader.cancel() }
    }

    private var content: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
                    .overlay(ProgressView())
            }
        }
    }
}

final class ImageLoader: ObservableObject {
    @Published var image: UIImage? = nil

    private var url: URL?
    private var task: Task<Void, Never>?

    init(url: URL?) { self.url = url }

    func load() {
        guard image == nil, let url = url else { return }

        if let cached = ImageCache.shared.image(forKey: url.absoluteString) {
            self.image = cached
            return
        }

        task = Task { @MainActor in
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let ui = UIImage(data: data) {
                    ImageCache.shared.insertImage(image, forKey: url.absoluteString)
                    self.image = ui
                }
            } catch {
                // ignore for now
            }
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}

