//
//  TVShows.swift
//  NetflixClone
//
//  Created by Net Solution on 8. 12. 2023..
//

import Foundation

struct TVShowsResponse: Codable {
    let results: [TVShows]
}

// Struct of variables that we get from API call and JSON file
struct TVShows: Codable {
    let id: Int
    let name: String?
    let original_name: String?
    let first_air_date: String?
    let vote_average: Float
    let vote_count: Int
}
