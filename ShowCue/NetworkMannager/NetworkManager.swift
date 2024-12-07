//
//  NetworkManager.swift
//  ShowCue
//
//  Created by mac on 07/12/2024.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
}


class NetworkManager {
    static let shared = NetworkManager()
    
    private let baseURL = "https://api.themoviedb.org/3"
    private let apiKey = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmYzhhY2RiNDVkMTcwNjhiZjA2MjZhNjI3NGI2MDRmZSIsIm5iZiI6MTczMzQ4ODE3OC4xNzUsInN1YiI6IjY3NTJlZTMyMzQ5NGNjOWJmYmM2MmQ2NyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.hPAaUZPmNzR7OdXENEmy6NhORgZ4vn4JbWxpp-MApGk"
    private let session = URLSession.shared
    
    private init() {}
    
    /// Fetches popular movies
    func getPopularMovies(completion: @escaping (Result<MoviesResponse, Error>) -> Void) {
        let urlString = "\(baseURL)/discover/movie?include_adult=false&include_video=false&language=en-US&page=1&sort_by=popularity.desc"
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "Authorization")
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let moviesResponse = try JSONDecoder().decode(MoviesResponse.self, from: data)
                completion(.success(moviesResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// Fetches details of a specific movie
    func getMovieDetails(id: Int, completion: @escaping (Result<MovieDetail, Error>) -> Void) {
        let urlString = "\(baseURL)/movie/\(id)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "Authorization")
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let movieDetail = try JSONDecoder().decode(MovieDetail.self, from: data)
                completion(.success(movieDetail))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
