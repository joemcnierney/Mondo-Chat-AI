// ChatSessionView.swift
// Version 2.1.5

import SwiftUI
import Combine

struct ChatSessionView: View {
    @Binding var selectedSessionId: Int?
    @Binding var chatSessions: [ChatSession]
    @AppStorage("userToken") var userToken: String = ""
    @AppStorage("userId") var userId: Int = 0

    @State private var messages: [Message] = []
    @State private var messageText: String = ""
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        VStack {
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
            if let sessionId = selectedSessionId {
                loadMessages(for: sessionId)
            }
        }
        .onChange(of: selectedSessionId) { newSessionId in
            if let sessionId = newSessionId {
                loadMessages(for: sessionId)
            }
        }
    }

    private func loadMessages(for sessionId: Int) {
        clearMessages() // Clear existing messages before loading new ones

        NetworkManager.shared.fetchMessages(userToken: userToken, sessionId: sessionId, userId: userId)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to fetch messages: \(error.localizedDescription)")
                }
            }, receiveValue: { fetchedMessages in
                self.messages = fetchedMessages // Only messages from the selected session
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
                self.messageText = ""
            })
            .store(in: &cancellables)
    }

    private func clearMessages() {
        self.messages = [] // Clear the messages array
    }
}

struct ChatSessionView_Previews: PreviewProvider {
    static var previews: some View {
        ChatSessionView(selectedSessionId: .constant(1), chatSessions: .constant([]))
    }
}
