//
//  Title.swift
//  NetflixClone
//
//  Created by Ahmed Halilovic on 6. 12. 2023..
//

import Foundation

struct TitleResponse: Codable {
    let results: [Title]
}

/// A movie or TV show returned by the TMDB API.
/// JSON snake_case keys are mapped automatically via `.convertFromSnakeCase`.
struct Title: Codable, Identifiable, Hashable {
    let id: Int
    let title: String?
    let originalLanguage: String?
    let originalTitle: String?
    let originalName: String?
    let overview: String?
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double?
    let voteCount: Int?

    /// Best available display name for the title.
    var displayTitle: String {
        title ?? originalTitle ?? originalName ?? "Untitled"
    }

    var posterURL: URL? {
        guard let posterPath else { return nil }
        return URL(string: APIConstants.imageBaseURL + posterPath)
    }

    var releaseYear: String? {
        guard let releaseDate, releaseDate.count >= 4 else { return nil }
        return String(releaseDate.prefix(4))
    }

    var formattedRating: String? {
        guard let voteAverage, voteAverage > 0 else { return nil }
        return String(format: "%.1f", voteAverage)
    }
}
