//
//  APICaller.swift
//  NetflixClone
//
//  Created by Ahmed Halilovic on 6. 12. 2023..
//

import Foundation

enum APIConstants {
    // Keys live in `Secrets.swift` (gitignored). Copy `Secrets.swift.example` to get started.
    static let tmdbAPIKey = Secrets.tmdbAPIKey
    static let tmdbBaseURL = "https://api.themoviedb.org/3"
    static let youtubeAPIKey = Secrets.youtubeAPIKey
    static let youtubeSearchURL = "https://youtube.googleapis.com/youtube/v3/search"
    static let imageBaseURL = "https://image.tmdb.org/t/p/w500"
}

enum APIError: LocalizedError {
    case invalidURL
    case requestFailed
    case decodingFailed
    case noResults

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The request URL could not be built."
        case .requestFailed: return "The network request failed. Check your connection and try again."
        case .decodingFailed: return "The server response could not be read."
        case .noResults: return "No results were found."
        }
    }
}

final class APICaller {

    static let shared = APICaller()

    enum TitlesEndpoint {
        case trendingMovies
        case trendingTV
        case popularMovies
        case upcomingMovies
        case topRatedMovies
        case discoverMovies
        case search(query: String)

        var path: String {
            switch self {
            case .trendingMovies: return "/trending/movie/day"
            case .trendingTV: return "/trending/tv/day"
            case .popularMovies: return "/movie/popular"
            case .upcomingMovies: return "/movie/upcoming"
            case .topRatedMovies: return "/movie/top_rated"
            case .discoverMovies: return "/discover/movie"
            case .search: return "/search/movie"
            }
        }

        var queryItems: [URLQueryItem] {
            switch self {
            case .trendingMovies, .trendingTV:
                return []
            case .popularMovies, .upcomingMovies, .topRatedMovies:
                return [URLQueryItem(name: "language", value: "en-US"),
                        URLQueryItem(name: "page", value: "1")]
            case .discoverMovies:
                return [URLQueryItem(name: "language", value: "en-US"),
                        URLQueryItem(name: "page", value: "1"),
                        URLQueryItem(name: "include_adult", value: "false"),
                        URLQueryItem(name: "sort_by", value: "popularity.desc")]
            case .search(let query):
                return [URLQueryItem(name: "query", value: query)]
            }
        }
    }

    private let session = URLSession.shared

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    private init() {}

    /// Fetches a list of titles from TMDB for the given endpoint.
    func titles(for endpoint: TitlesEndpoint) async throws -> [Title] {
        var components = URLComponents(string: APIConstants.tmdbBaseURL + endpoint.path)
        components?.queryItems = [URLQueryItem(name: "api_key", value: APIConstants.tmdbAPIKey)] + endpoint.queryItems

        guard let url = components?.url else { throw APIError.invalidURL }
        return try await fetch(TitleResponse.self, from: url).results
    }

    /// Searches YouTube for the official trailer of the given title.
    func trailer(forTitleNamed name: String) async throws -> VideoElement {
        var components = URLComponents(string: APIConstants.youtubeSearchURL)
        components?.queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "type", value: "video"),
            URLQueryItem(name: "videoEmbeddable", value: "true"),
            URLQueryItem(name: "maxResults", value: "1"),
            URLQueryItem(name: "q", value: "\(name) trailer"),
            URLQueryItem(name: "key", value: APIConstants.youtubeAPIKey)
        ]

        guard let url = components?.url else { throw APIError.invalidURL }
        let response = try await fetch(YoutubeSearchResponse.self, from: url)

        guard let video = response.items.first, video.id.videoId != nil else {
            throw APIError.noResults
        }
        return video
    }

    private func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw APIError.requestFailed
        }

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }
}
