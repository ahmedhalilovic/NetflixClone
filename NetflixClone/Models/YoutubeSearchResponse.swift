//
//  YoutubeSearchResponse.swift
//  NetflixClone
//
//  Created by Net Solution on 13. 12. 2023..
//

import Foundation

struct YoutubeSearchResponse: Codable {
    let items: [VideoElement]
}

struct VideoElement: Codable {
    let id: idVideoElement
}

struct idVideoElement: Codable {
    let kind: String
    let videoId: String
}
