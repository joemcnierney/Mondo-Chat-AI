// NetworkManager.swift
// Version 1.8.1

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    // MARK: - Create Chat Session
    func createChatSession(userToken: String, userId: Int, sessionTitle: String, completion: @escaping (Result<ChatSession, Error>) -> Void) {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:ypqbxXlC/chat_sessions") else {
            print("Invalid URL")
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Pass the correct user ID as an integer
        let body: [String: Any] = ["session_title": sessionTitle, "user_id": userId, "updated_at": NSNull()]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error during session creation: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                print("No data or response during session creation")
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            guard response.statusCode == 200 else {
                print("Unexpected status code: \(response.statusCode)")
                print("Response data: \(String(data: data, encoding: .utf8) ?? "No data")")
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            do {
                let session = try JSONDecoder().decode(ChatSession.self, from: data)
                print("Session decoded successfully: \(session)")
                completion(.success(session))
            } catch {
                print("Failed to decode session: \(error.localizedDescription)")
                print("Response data: \(String(data: data, encoding: .utf8) ?? "No data")")
                completion(.failure(NetworkError.parsingError))
            }
        }.resume()
    }

    // MARK: Update Chat Session Title

    func updateChatSessionTitle(userToken: String, sessionId: Int, userId: Int, newTitle: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:ypqbxXlC/chat_sessions/\(sessionId)") else {
            print("Invalid URL")
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Include user_id and session_title in the PATCH request body
        let body: [String: Any] = ["chat_sessions_id": sessionId, "session_title": newTitle, "user_id": userId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to update chat session title: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Unexpected response code during title update")
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            completion(.success(()))
        }.resume()
    }
    
    // MARK: - Fetch Chat Sessions
    func fetchChatSessions(userToken: String, completion: @escaping (Result<[ChatSession], Error>) -> Void) {
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
                print("Network error during session fetch: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let data = data, let response = response as? HTTPURLResponse else {
                print("No data or response during session fetch")
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            guard response.statusCode == 200 else {
                print("Unexpected status code: \(response.statusCode)")
                print("Response data: \(String(data: data, encoding: .utf8) ?? "No data")")
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            do {
                let sessions = try JSONDecoder().decode([ChatSession].self, from: data)
                print("Successfully decoded chat sessions: \(sessions.count) sessions")
                completion(.success(sessions))
            } catch {
                print("Failed to decode chat sessions: \(error.localizedDescription)")
                print("Response data: \(String(data: data, encoding: .utf8) ?? "No data")")
                completion(.failure(NetworkError.parsingError))
            }
        }.resume()
    }

    // MARK: - Send Message
    func sendMessage(userToken: String, userId: Int, sessionId: Int, message: Message, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:ypqbxXlC/messages") else {
            print("Invalid URL")
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "session_id": sessionId,
            "user_id": userId, // Pass the correct user ID as an integer
            "content": message.content,
            "is_from_current_user": message.isFromCurrentUser
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to send message: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Invalid response during message send")
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            print("Message sent successfully.")
            completion(.success(()))
        }.resume()
    }
    
    // MARK: - Fetch Messages
    func fetchMessages(userToken: String, sessionId: Int, userId: Int?, completion: @escaping (Result<[Message], Error>) -> Void) {
        // Construct the URL with chat_sessions_id and optionally users_id
        var urlString = "https://x8ki-letl-twmt.n7.xano.io/api:ypqbxXlC/messages?chat_sessions_id=\(sessionId)"
        
        // If userId is provided, append it to the URL
        if let userId = userId {
            urlString.append("&users_id=\(userId)")
        }
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to fetch messages: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Invalid response or data during message fetch")
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            do {
                let messages = try JSONDecoder().decode([Message].self, from: data)
                print("Fetched messages successfully: \(messages.count) messages")
                completion(.success(messages))
            } catch {
                print("Failed to decode messages: \(error.localizedDescription)")
                completion(.failure(NetworkError.parsingError))
            }
        }.resume()
    }

    // MARK: - Login User
    func loginUser(email: String, password: String, completion: @escaping (Result<(String, Int), Error>) -> Void) {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:uoSb7QpQ/auth/login") else {
            print("Invalid URL")
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
                print("Failed to log in: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Invalid response or data during login")
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let token = json["authToken"] as? String {
                    // Fetch user details with auth/me to get userId
                    self.getUserDetails(token: token) { result in
                        switch result {
                        case .success(let userId):
                            completion(.success((token, userId)))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                } else {
                    print("Failed to parse token during login")
                    completion(.failure(NetworkError.parsingError))
                }
            } catch {
                print("Failed to decode response during login: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
    // MARK: - User Details
    func getUserDetails(token: String, completion: @escaping (Result<Int, Error>) -> Void) {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:uoSb7QpQ/auth/me") else {
            print("Invalid URL")
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to fetch user details: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Invalid response or data during user fetch")
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let userId = json["id"] as? Int {
                    completion(.success(userId))
                } else {
                    print("Failed to parse user details")
                    completion(.failure(NetworkError.parsingError))
                }
            } catch {
                print("Failed to decode user details: \(error.localizedDescription)")
                completion(.failure(error))
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
