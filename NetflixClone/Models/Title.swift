//
//  Movie.swift
//  NetflixClone
//
//  Created by Net Solution on 6. 12. 2023..
//

import Foundation

struct TrendingTitleResponse: Codable {
    let results: [Title]
}

// Struct of variables that we get from API call and JSON file
struct Title: Codable {
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
