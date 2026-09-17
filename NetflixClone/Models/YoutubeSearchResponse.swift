//
//  YoutubeSearchResponse.swift
//  NetflixClone
//
//  Created by Ahmed Halilovic on 13. 12. 2023..
//

import Foundation

struct YoutubeSearchResponse: Codable {
    let items: [VideoElement]
}

struct VideoElement: Codable, Hashable {
    let id: VideoID
}

struct VideoID: Codable, Hashable {
    let kind: String
    let videoId: String?
}
