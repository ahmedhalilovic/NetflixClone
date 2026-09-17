//
//  TitlePreviewViewModel.swift
//  NetflixClone
//
//  Created by Ahmed Halilovic on 13. 12. 2023..
//

import Foundation

struct TitlePreviewViewModel {
    let title: Title
    /// The YouTube trailer, if one was found. When `nil` the preview falls back to the poster art.
    let trailer: VideoElement?

    var trailerURL: URL? {
        guard let videoId = trailer?.id.videoId else { return nil }
        return URL(string: "https://www.youtube.com/embed/\(videoId)?playsinline=1")
    }
}
