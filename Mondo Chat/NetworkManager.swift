// NetworkManager.swift
// Version 0.2.1

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}

    // MARK: - Create Chat Session
    func createChatSession(userToken: String, completion: @escaping (Result<Int, Error>) -> Void) {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:ypqbxXlC/chat_sessions") else {
            print("Invalid URL")
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any?] = ["session_title": "New Chat", "updated_at": NSNull()]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error creating chat session: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("No data received")
                completion(.failure(NetworkError.noData))
                return
            }

            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let sessionId = jsonResponse["id"] as? Int {
                completion(.success(sessionId))
            } else {
                print("Failed to parse JSON response")
                completion(.failure(NetworkError.parsingFailed))
            }
        }.resume()
    }

    // MARK: - Update Chat Session
    func updateChatSession(sessionId: String, title: String, userToken: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:ypqbxXlC/chat_sessions/\(sessionId)") else {
            print("Invalid URL")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["session_title": title, "updated_at": Date().timeIntervalSince1970]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to update chat session: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }.resume()
    }

    // MARK: - Store Message
    func storeMessage(in sessionId: String, content: String, userToken: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:ypqbxXlC/messages") else {
            print("Invalid URL")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["session_id": sessionId, "content": content]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to store message: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }.resume()
    }

    // MARK: - Get Chat Sessions
    func getChatSessions(userToken: String, completion: @escaping (Result<[ChatSession], Error>) -> Void) {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:ypqbxXlC/chat_sessions") else {
            print("Invalid URL")
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching chat sessions: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("No data received")
                completion(.failure(NetworkError.noData))
                return
            }

            do {
                let sessions = try JSONDecoder().decode([ChatSession].self, from: data)
                completion(.success(sessions))
            } catch {
                print("Failed to decode chat sessions: \(error.localizedDescription)")
                completion(.failure(NetworkError.parsingFailed))
            }
        }.resume()
    }

    // MARK: - Get Messages
    func getMessages(for sessionId: String, userToken: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:ypqbxXlC/messages?session_id=\(sessionId)") else {
            print("Invalid URL")
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching messages: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("No data received")
                completion(.failure(NetworkError.noData))
                return
            }

            do {
                let messages = try JSONDecoder().decode([Message].self, from: data)
                completion(.success(messages))
            } catch {
                print("Failed to decode messages: \(error.localizedDescription)")
                completion(.failure(NetworkError.parsingFailed))
            }
        }.resume()
    }
}

// MARK: - Network Error Enum
enum NetworkError: Error {
    case invalidURL
    case noData
    case parsingFailed
}
