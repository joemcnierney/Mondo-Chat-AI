// ContentView.swift
// Mondo Chat App
// Version 1.2.0

import SwiftUI
import Combine

struct ContentView: View {
    @State private var messageText: String = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var isMenuOpen: Bool = false
    @State private var chatSessionId: String?
    @State private var messages: [Message] = []
    @State private var sessionTitle: String = "Temporary Chat"
    @State private var isEditingSessionTitle: Bool = false
    @AppStorage("userToken") var userToken: String = ""

    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Top bar with menu icon and edit icon
                HStack {
                    // Menu Icon
                    Button(action: {
                        isMenuOpen.toggle()
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.black)
                            .padding(.leading, 16)
                    }
                    .sheet(isPresented: $isMenuOpen) {
                        MenuView()
                    }

                    Spacer()

                    // Session Title with Edit Capability
                    TextField("", text: $sessionTitle, onCommit: updateSessionTitle)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .disabled(!isEditingSessionTitle)
                        .frame(maxWidth: geometry.size.width * 0.6)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .onLongPressGesture {
                            isEditingSessionTitle.toggle()
                        }

                    Spacer()

                    // Edit Icon Placeholder
                    Image(systemName: "square.and.pencil")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                        .padding(.trailing, 16)
                }

                // Chat Bubbles
                ScrollView {
                    ForEach(messages) { message in
                        HStack {
                            if message.isFromCurrentUser {
                                Spacer()
                                Text(message.text)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(12)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: geometry.size.width * 0.7, alignment: .trailing)
                            } else {
                                Text(message.text)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(12)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: geometry.size.width * 0.7, alignment: .leading)
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                    }
                }

                Spacer()

                // Message input field
                HStack {
                    TextField("Message", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 16)

                    Button(action: {
                        sendMessage()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.purple)
                            .padding(.trailing, 16)
                    }
                }
                .padding(.bottom, keyboardHeight > 0 ? keyboardHeight : 40)
                .onReceive(Publishers.keyboardHeight) { height in
                    withAnimation(.easeOut(duration: 0.3)) {
                        self.keyboardHeight = height
                    }
                }
            }
            .edgesIgnoringSafeArea(.horizontal)
            .edgesIgnoringSafeArea(.bottom)
        }
    }

    // MARK: - Send Message Function
    private func sendMessage() {
        guard !messageText.isEmpty else {
            print("Message is empty, not sending.")
            return
        }

        print("Sending message: \(messageText)")

        if let sessionId = chatSessionId {
            print("Session ID exists: \(sessionId). Storing message.")
            storeMessage(in: sessionId)
        } else {
            print("No Session ID, creating new chat session.")
            createChatSession { sessionId in
                guard let sessionId = sessionId else {
                    print("Failed to create chat session.")
                    return
                }
                self.chatSessionId = sessionId
                self.storeMessage(in: sessionId)
            }
        }
    }

    // MARK: - Create Chat Session Function
    private func createChatSession(completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:ypqbxXlC/chat_sessions") else {
            print("Invalid URL for chat session creation")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["session_title": sessionTitle, "updated_at": NSNull()]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error creating chat session: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received when creating chat session")
                completion(nil)
                return
            }

            // Log the raw JSON response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON response: \(jsonString)")
            } else {
                print("Unable to convert data to JSON string")
            }

            // Attempt to parse the JSON and extract the session ID
            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let sessionId = jsonResponse["id"] as? Int {
                DispatchQueue.main.async {
                    print("Session ID created: \(sessionId)")
                    completion("\(sessionId)") // Convert Int to String for further use
                }
            } else {
                print("Failed to parse JSON response or session ID not found")
                completion(nil)
            }
        }.resume()
    }

    // MARK: - Store Message Function
    private func storeMessage(in sessionId: String) {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:ypqbxXlC/messages") else {
            print("Invalid URL for storing message")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["session_id": sessionId, "content": messageText, "sender": "user"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to store message: \(error.localizedDescription)")
                    return
                }
                print("Message stored successfully")
                self.messages.append(Message(text: self.messageText, isFromCurrentUser: true))
                self.messageText = "" // Clear the input field after sending
            }
        }.resume()
    }

    // MARK: - Update Session Title Function
    private func updateSessionTitle() {
        guard let sessionId = chatSessionId else {
            print("No active session to update.")
            return
        }

        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:ypqbxXlC/chat_sessions/\(sessionId)") else {
            print("Invalid URL for updating session title")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["session_title": sessionTitle, "updated_at": Int(Date().timeIntervalSince1970 * 1000)]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to update session title: \(error.localizedDescription)")
                    return
                }
                print("Session title updated successfully")
                self.isEditingSessionTitle = false
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isFromCurrentUser: Bool
}

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}
