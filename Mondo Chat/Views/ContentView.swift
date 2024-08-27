// ContentView.swift
// Version 2.0.0

import SwiftUI
import Combine

struct ContentView: View {
    @State private var selectedSessionId: Int? = nil
    @State private var chatSessions: [ChatSession] = []
    @State private var isMenuOpen: Bool = false
    @State private var messageText: String = ""
    @State private var messages: [Message] = []
    @State private var messageCache: [Int: [Message]] = [:] // Cache for messages
    @State private var showRenameSheet: Bool = false
    @State private var newTitle: String = ""
    @State private var isTokenExpired: Bool = false
    @State private var navigateToLogin: Bool = false
    @AppStorage("userToken") var userToken: String = ""
    @AppStorage("userId") var userId: Int = 0 // Ensure userId is stored as an Int
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        VStack {
            if isTokenExpired {
                Text("Session expired, please log in again.")
                Button(action: {
                    navigateToLogin = true
                }) {
                    Text("Login")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .fullScreenCover(isPresented: $navigateToLogin) {
                    LoginView()
                }
            } else {
                // Top bar with chat session name, menu icon, and create session button
                HStack {
                    // Menu Icon
                    Button(action: {
                        isMenuOpen.toggle()
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding()
                    }

                    Spacer()

                    // Display the current chat session name
                    if let selectedSessionId = selectedSessionId,
                       let session = chatSessions.first(where: { $0.id == selectedSessionId }) {
                        Text(session.title)
                            .font(.headline)
                            .onTapGesture {
                                newTitle = session.title
                                showRenameSheet = true
                            }
                    } else {
                        Text("No Chat Selected")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // Create new session button
                    Button(action: {
                        createNewChatSession()
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding()
                    }
                }
                .padding()

                // Chat sessions and messages view
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
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $isMenuOpen) {
            MenuView(chatSessions: $chatSessions, selectedSessionId: $selectedSessionId)
                .transition(.move(edge: .leading))
        }
        .sheet(isPresented: $showRenameSheet) {
            renameChatSheet()
        }
        .onAppear {
            checkTokenAndFetchSessions()
        }
    }

    private func checkTokenAndFetchSessions() {
        if userToken.isEmpty {
            isTokenExpired = true
        } else {
            fetchChatSessions()
        }
    }

    private func fetchChatSessions() {
        NetworkManager.shared.fetchChatSessions(userToken: userToken)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    if case NetworkError.invalidResponse = error {
                        isTokenExpired = true
                    }
                    print("Failed to fetch chat sessions: \(error.localizedDescription)")
                }
            }, receiveValue: { sessions in
                self.chatSessions = sessions
                if self.selectedSessionId == nil, let firstSession = sessions.first {
                    self.selectedSessionId = firstSession.id
                    fetchMessages(for: firstSession.id)
                }
            })
            .store(in: &cancellables)
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

    private func createNewChatSession() {
        NetworkManager.shared.createChatSession(userToken: userToken, userId: userId, sessionTitle: "New Chat")
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to create chat session: \(error.localizedDescription)")
                }
            }, receiveValue: { newSession in
                self.chatSessions.append(newSession)
                self.selectedSessionId = newSession.id
                self.messages = [] // Reset messages for new session
            })
            .store(in: &cancellables)
    }

    private func renameChatSheet() -> some View {
        VStack {
            Text("Rename Chat")
                .font(.headline)
                .padding()

            TextField("New Chat Title", text: $newTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: saveChatTitle) {
                Text("Save")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            Button(action: { showRenameSheet = false }) {
                Text("Cancel")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }

    private func saveChatTitle() {
        guard let sessionId = selectedSessionId,
              let sessionIndex = chatSessions.firstIndex(where: { $0.id == sessionId }) else { return }

        let oldTitle = chatSessions[sessionIndex].title
        chatSessions[sessionIndex].title = newTitle
        showRenameSheet = false

        // Update the session title on the server
        NetworkManager.shared.updateChatSessionTitle(userToken: userToken, sessionId: sessionId, userId: userId, newTitle: newTitle)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to update chat session title: \(error.localizedDescription)")
                    chatSessions[sessionIndex].title = oldTitle // Revert to the old title in case of failure
                }
            }, receiveValue: {
                print("Chat session title updated successfully.")
            })
            .store(in: &cancellables)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
