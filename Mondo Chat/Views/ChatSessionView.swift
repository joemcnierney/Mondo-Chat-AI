// ChatSessionView.swift
// Version 2.0.0

import SwiftUI
import Combine

struct ChatSessionView: View {
    @Binding var selectedSessionId: Int?
    @Binding var chatSessions: [ChatSession]
    @AppStorage("userToken") var userToken: String = ""
    @AppStorage("userId") var userId: Int = 0

    @State private var messages: [Message] = []
    @State private var messageText: String = ""
    @State private var messageCache: [Int: [Message]] = [:] // Cache for messages
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        VStack {
            // Chat messages display
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(messages) { message in
                            HStack {
                                if message.isFromCurrentUser {
                                    Spacer()
                                    Text(message.content)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(12)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                } else {
                                    Text(message.content)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(12)
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                    .onAppear {
                        if let lastMessage = messages.last {
                            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            Spacer()

            // Message input field and send button, anchored at the bottom
            HStack {
                TextField("Enter your message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading, 10)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding()
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .ignoresSafeArea(edges: .bottom)
        }
        .onAppear {
            loadMessages()
        }
        .onChange(of: selectedSessionId) { newSessionId in
            if let sessionId = newSessionId {
                loadMessages(for: sessionId)
            }
        }
    }

    private func loadMessages(for sessionId: Int? = nil) {
        guard let sessionId = sessionId ?? selectedSessionId else { return }

        // Load messages from cache or fetch from server
        if let cachedMessages = messageCache[sessionId] {
            self.messages = cachedMessages
        } else {
            fetchMessages(for: sessionId)
        }
    }

    private func fetchMessages(for sessionId: Int) {
        NetworkManager.shared.fetchMessages(userToken: userToken, sessionId: sessionId, userId: userId)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to fetch messages: \(error.localizedDescription)")
                }
            }, receiveValue: { fetchedMessages in
                self.messages = fetchedMessages
                self.messageCache[sessionId] = fetchedMessages // Cache the fetched messages
            })
            .store(in: &cancellables)
    }

    private func sendMessage() {
        guard let sessionId = selectedSessionId, !messageText.isEmpty else {
            print("No session selected or message is empty")
            return
        }

        let newMessage = Message(id: UUID().hashValue, content: messageText, isFromCurrentUser: true, createdAt: Date().timeIntervalSince1970)

        // Send the message to Xano
        NetworkManager.shared.sendMessage(userToken: userToken, userId: userId, sessionId: sessionId, message: newMessage)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to send message: \(error.localizedDescription)")
                }
            }, receiveValue: {
                print("Message sent successfully.")
                self.messages.append(newMessage)
                self.messageCache[sessionId] = self.messages // Update the cache
                self.messageText = ""
            })
            .store(in: &cancellables)
    }
}

struct ChatSessionView_Previews: PreviewProvider {
    static var previews: some View {
        ChatSessionView(selectedSessionId: .constant(1), chatSessions: .constant([]))
    }
}
