//  NetworkManager.swift
//  Version 1.0.0

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://x8ki-letl-twmt.n7.xano.io/api:ypqbxXlC"
    private var userToken: String {
        UserDefaults.standard.string(forKey: "userToken") ?? ""
    }

    private init() {}

    // MARK: - Endpoint for Chat Sessions
    func createChatSession(title: String, completion: @escaping (Result<Int, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/chat_sessions") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["session_title": title, "updated_at": NSNull()]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        performRequest(request: request, completion: completion)
    }
    
    func updateChatSession(sessionId: Int, title: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/chat_sessions/\(sessionId)") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["session_title": title, "updated_at": Date().timeIntervalSince1970]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        performVoidRequest(request: request, completion: completion)
    }

    // MARK: - Endpoint for Messages
    func storeMessage(sessionId: Int, content: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/messages") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["session_id": sessionId, "content": content]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        performVoidRequest(request: request, completion: completion)
    }

    // MARK: - Generic Request Functions
    private func performRequest<T: Decodable>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    private func performVoidRequest(request: URLRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // If there's no data, we return success for a Void response.
            completion(.success(()))
        }.resume()
    }

    // MARK: - Custom Error Types
    enum NetworkError: Error {
        case invalidURL
        case noData
    }
}
