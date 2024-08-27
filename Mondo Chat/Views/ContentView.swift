// ContentView.swift
// Version 1.8.4

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
                        .onChange(of: messages.count) {
                            scrollView.scrollTo(messages.last?.id, anchor: .bottom)
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
        .onChange(of: selectedSessionId) { _, newSessionId in
            if let sessionId = newSessionId {
                loadMessages(for: sessionId)
            }
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
        NetworkManager.shared.fetchChatSessions(userToken: userToken) { result in
            switch result {
            case .success(let sessions):
                self.chatSessions = sessions
                if self.selectedSessionId == nil, let firstSession = sessions.first {
                    self.selectedSessionId = firstSession.id
                    loadMessages(for: firstSession.id)
                }
            case .failure(let error):
                if case NetworkError.invalidResponse = error {
                    print("Failed to fetch chat sessions: \(error.localizedDescription)")
                    isTokenExpired = true
                } else {
                    print("Failed to fetch chat sessions: \(error.localizedDescription)")
                }
            }
        }
    }

    private func loadMessages(for sessionId: Int) {
        // Load messages from cache or fetch from server
        if let cachedMessages = messageCache[sessionId] {
            self.messages = cachedMessages
        } else {
            fetchMessages(for: sessionId)
        }
    }

    private func fetchMessages(for sessionId: Int) {
        NetworkManager.shared.fetchMessages(userToken: userToken, sessionId: sessionId, userId: userId) { result in
            switch result {
            case .success(let fetchedMessages):
                self.messages = fetchedMessages
                self.messageCache[sessionId] = fetchedMessages // Cache the fetched messages
            case .failure(let error):
                print("Failed to fetch messages: \(error.localizedDescription)")
            }
        }
    }

    private func sendMessage() {
        guard let sessionId = selectedSessionId, !messageText.isEmpty else {
            print("No session selected or message is empty")
            return
        }

        let newMessage = Message(id: UUID().hashValue, content: messageText, isFromCurrentUser: true, createdAt: Date().timeIntervalSince1970)

        // Send the message to Xano
        NetworkManager.shared.sendMessage(userToken: userToken, userId: userId, sessionId: sessionId, message: newMessage) { result in
            switch result {
            case .success(_):
                print("Message sent successfully.")
                self.messages.append(newMessage)
                self.messageCache[sessionId] = self.messages // Update the cache
                self.messageText = ""
            case .failure(let error):
                print("Failed to send message: \(error.localizedDescription)")
            }
        }
    }

    private func createNewChatSession() {
        NetworkManager.shared.createChatSession(userToken: userToken, userId: userId, sessionTitle: "New Chat") { result in
            switch result {
            case .success(let newSession):
                self.chatSessions.append(newSession)
                self.selectedSessionId = newSession.id
                self.messages = [] // Reset messages for new session
                self.messageCache[newSession.id] = [] // Initialize empty cache for new session
            case .failure(let error):
                print("Failed to create chat session: \(error.localizedDescription)")
            }
        }
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
        NetworkManager.shared.updateChatSessionTitle(userToken: userToken, sessionId: sessionId, userId: userId, newTitle: newTitle) { result in
            switch result {
            case .success:
                print("Chat session title updated successfully.")
            case .failure(let error):
                print("Failed to update chat session title: \(error.localizedDescription)")
                // Revert to the old title in case of failure
                chatSessions[sessionIndex].title = oldTitle
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
