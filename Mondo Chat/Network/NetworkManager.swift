// NetworkManager.swift
// Version 2.0.4

import Foundation
import Combine
import Starscream

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}

    // MARK: - Create Chat Session
    func createChatSession(userToken: String, userId: Int, sessionTitle: String) -> AnyPublisher<ChatSession, Error> {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:ypqbxXlC/chat_sessions") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["session_title": sessionTitle, "user_id": userId, "updated_at": NSNull()]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("Failed to create chat session: \(String(data: output.data, encoding: .utf8) ?? "No Data")")
                    throw NetworkError.invalidResponse
                }
                return output.data
            }
            .decode(type: ChatSession.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }


    // MARK: - Fetch Chat Sessions
    func fetchChatSessions(userToken: String) -> AnyPublisher<[ChatSession], Error> {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:ypqbxXlC/chat_sessions") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("Failed to fetch chat sessions: \(String(data: output.data, encoding: .utf8) ?? "No Data")")
                    throw NetworkError.invalidResponse
                }
                return output.data
            }
            .decode(type: [ChatSession].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }


    // MARK: - Fetch Messages
    func fetchMessages(userToken: String, sessionId: Int, userId: Int?) -> AnyPublisher<[Message], Error> {
        var urlString = "https://x8ki-letl-twmt.n7.xano.io/api:ypqbxXlC/messages?chat_sessions_id=\(sessionId)"
        if let userId = userId {
            urlString.append("&users_id=\(userId)")
        }

        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("Failed to fetch messages: \(String(data: output.data, encoding: .utf8) ?? "No Data")")
                    throw NetworkError.invalidResponse
                }
                return output.data
            }
            .decode(type: [Message].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }


    // MARK: - Send Message
    func sendMessage(userToken: String, userId: Int, sessionId: Int, message: Message) -> AnyPublisher<Void, Error> {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:ypqbxXlC/messages") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "content": message.content,
            "session_id": sessionId,
            "user_id": userId,
            "is_from_current_user": message.isFromCurrentUser,
            "created_at": message.createdAt ?? Date().timeIntervalSince1970
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("Failed to send message: \(String(data: output.data, encoding: .utf8) ?? "No Data")")
                    throw NetworkError.invalidResponse
                }
                return ()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }


    // MARK: - Update Chat Session Title
    func updateChatSessionTitle(userToken: String, sessionId: Int, userId: Int, newTitle: String) -> AnyPublisher<Void, Error> {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:ypqbxXlC/chat_sessions/\(sessionId)") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "session_title": newTitle,
            "user_id": userId
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("Failed to update chat session title: \(String(data: output.data, encoding: .utf8) ?? "No Data")")
                    throw NetworkError.invalidResponse
                }
                return ()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }


    // MARK: - Sign-Up User
    func signUpUser(name: String, email: String, password: String) -> AnyPublisher<(String, Int), Error> {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:uoSb7QpQ/auth/signup") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["name": name, "email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("Failed to sign up: \(String(data: output.data, encoding: .utf8) ?? "No Data")")
                    throw NetworkError.invalidResponse
                }
                guard let json = try? JSONSerialization.jsonObject(with: output.data, options: []) as? [String: Any],
                      let token = json["authToken"] as? String,
                      let userId = json["user_id"] as? Int else {
                    print("Failed to parse sign-up response")
                    throw NetworkError.parsingError
                }
                return (token, userId)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: - Login User
    func loginUser(email: String, password: String) -> AnyPublisher<(String, Int), Error> {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:uoSb7QpQ/auth/login") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("Failed to login: \(String(data: output.data, encoding: .utf8) ?? "No Data")")
                    throw NetworkError.invalidResponse
                }

                guard let json = try? JSONSerialization.jsonObject(with: output.data, options: []) as? [String: Any],
                      let token = json["authToken"] as? String,
                      let userId = json["user_id"] as? Int else {
                    print("Failed to parse login response")
                    throw NetworkError.parsingError
                }

                return (token, userId)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }


    // MARK: - Fetch User Details
    func getUserDetails(token: String) -> AnyPublisher<Int, Error> {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:uoSb7QpQ/auth/me") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw NetworkError.invalidResponse
                }
                guard let json = try? JSONSerialization.jsonObject(with: output.data, options: []) as? [String: Any],
                      let userId = json["id"] as? Int else {
                    throw NetworkError.parsingError
                }
                return userId
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Network Errors
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case parsingError
}
