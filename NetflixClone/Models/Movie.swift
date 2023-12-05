//
//  Movie.swift
//  NetflixClone
//
//  Created by Net Solution on 6. 12. 2023..
//

import Foundation

struct TrendingMoviesResponse: Codable {
    let results: [Movie]
}

// Struct of variables that we get from API call and JSON file
struct Movie: Codable {
    let id: Int
    let title: String?
    let original_language: String?
    let original_title: String?
    let overview: String?
    let poster_path: String?
    let release_date: String?
    let vote_average: Float
    let vote_count: Int
}
