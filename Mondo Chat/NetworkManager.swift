// NetworkManager.swift
// Version 0.0.1

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func createChatSession(userToken: String, completion: @escaping (Result<Int, Error>) -> Void) {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:ypqbxXlC/chat_sessions") else {
            print("Invalid URL")
            completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
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
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("No data received")
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }

            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let sessionId = jsonResponse["id"] as? Int {
                completion(.success(sessionId))
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
            }
        }.resume()
    }

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
}
