//
//  APICaller.swift
//  NetflixClone
//
//  Created by Net Solution on 6. 12. 2023..
//

import Foundation

struct Constant {
    static let API_KEY = "481e510b8fbfb491962e90775c075cc5"
    static let baseURL = "https://api.themoviedb.org"
}

enum APIError: Error {
    case failedToGetData
}

class APICaller {
    static let shared = APICaller()
    
    // Get array of Trending Movies from API
    func getTrendingMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let url = URL(string: "\(Constant.baseURL)/3/trending/movie/day?api_key=\(Constant.API_KEY)") else { return }
        
        // Task for making url calls
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            // Converting data to JSON object so we can serialise it and use it more easily
            do {
                
                let results = try JSONDecoder().decode(TrendingMoviesResponse.self, from: data)
                completion(.success(results.results))
                
            }catch {
                completion(.failure(error))
            }
        }
        
        task.resume()

    }
    
    // Get array of Trending TV Shows from API
    func getTrendingTVShows(completion: @escaping (Result<[TVShows], Error>) -> Void) {
        guard let url = URL(string: "\(Constant.baseURL)/3/trending/tv/day?api_key=\(Constant.API_KEY)") else { return }
        
        // Task for making url calls
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            // Converting data to JSON object so we can serialise it and use it more easily
            do {
                
                let results = try JSONDecoder().decode(TVShowsResponse.self, from: data)
                completion(.success(results.results))
                
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
        
    }
    
    
    // Get array of Popular Movies from API
    func getPopular(completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let url = URL(string: "\(Constant.baseURL)/3/movie/popular?api_key=\(Constant.API_KEY)&language=en-US&page=1") else { return }
        
        // Task for making URL calls
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let results = try JSONDecoder().decode(TrendingMoviesResponse.self, from: data)
                print(results)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        task.resume()
        
    }
    
    // Get array of Upcoming Movies from API
    func getUpcomingMovies(completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let url = URL(string: "\(Constant.baseURL)/3/movie/upcoming?api_key=\(Constant.API_KEY)&language=en-US&page=1") else { return }
        
        // Task for making URL calls
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let results = try JSONDecoder().decode(TrendingMoviesResponse.self, from: data)
                print(results)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        task.resume()
    }

    
    // Get Top Rated Movies from API
    func getTopRated(completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let url = URL(string: "\(Constant.baseURL)/3/movie/top_rated?api_key=\(Constant.API_KEY)&language=en-US&page=1") else { return }
        
        // Task for making URL calls
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                
                let results = try JSONDecoder().decode(TrendingMoviesResponse.self, from: data)
                print(results)
                
            } catch {
                print(error.localizedDescription)
            }
        }
        
        task.resume()
        
    }
    
}

// popular
// https://api.themoviedb.org/3/movie/popular?api_key=481e510b8fbfb491962e90775c075cc5&language=en-US&page=1

//top rated
//https://api.themoviedb.org/3/movie/top_rated?api_key=481e510b8fbfb491962e90775c075cc5&language=en-US&page=1
