// NetworkManager.swift
// Version 1.2.0

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    // MARK: - Login User
    func loginUser(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:uoSb7QpQ/auth/login") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let token = json["authToken"] as? String {
                    completion(.success(token))
                } else {
                    completion(.failure(NetworkError.parsingError))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Create Chat Session
    func createChatSession(userToken: String, sessionTitle: String, completion: @escaping (Result<ChatSession, Error>) -> Void) {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:ypqbxXlC/chat_sessions") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any?] = ["session_title": sessionTitle, "updated_at": NSNull()]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            do {
                let session = try JSONDecoder().decode(ChatSession.self, from: data)
                completion(.success(session))
            } catch {
                completion(.failure(NetworkError.parsingError))
            }
        }.resume()
    }
    
    // MARK: - Fetch Chat Sessions
    func fetchChatSessions(userToken: String, completion: @escaping (Result<[ChatSession], Error>) -> Void) {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:ypqbxXlC/chat_sessions") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            do {
                let sessions = try JSONDecoder().decode([ChatSession].self, from: data)
                completion(.success(sessions))
            } catch {
                completion(.failure(NetworkError.parsingError))
            }
        }.resume()
    }

    // MARK: - Send Message
    func sendMessage(userToken: String, sessionId: Int, message: Message, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:ypqbxXlC/messages") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "session_id": sessionId,
            "user_id": userToken, // Assuming userToken is also serving as a user ID, adjust if necessary
            "content": message.content,
            "is_from_current_user": message.isFromCurrentUser
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
    
    // MARK: - Fetch Messages
    func fetchMessages(userToken: String, sessionId: Int, completion: @escaping (Result<[Message], Error>) -> Void) {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:ypqbxXlC/messages?session_id=\(sessionId)&user_id=\(userToken)") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            do {
                let messages = try JSONDecoder().decode([Message].self, from: data)
                completion(.success(messages))
            } catch {
                completion(.failure(NetworkError.parsingError))
            }
        }.resume()
    }
}

// MARK: - Network Errors
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case parsingError
}
