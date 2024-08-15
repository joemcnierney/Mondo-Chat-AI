// ContentView.swift
// Version 0.2.2

import SwiftUI
import Combine

struct ContentView: View {
    @State private var selectedSessionId: Int?
    @State private var chatSessions: [ChatSession] = []
    @State private var isMenuOpen: Bool = false
    @State private var messageText: String = ""
    @State private var messages: [Message] = []
    @State private var isRenameSheetOpen: Bool = false
    @State private var newSessionTitle: String = ""
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
                        MenuView(chatSessions: $chatSessions, selectedSessionId: $selectedSessionId)
                    }

                    Spacer()

                    // Chat Session Title
                    if let sessionId = selectedSessionId, let session = chatSessions.first(where: { $0.id == sessionId }) {
                        Text(session.title)
                            .font(.headline)
                            .onTapGesture {
                                newSessionTitle = session.title
                                isRenameSheetOpen = true
                            }
                    } else {
                        Text("New Chat")
                            .font(.headline)
                    }

                    Spacer()

                    // New Session Button
                    Button(action: {
                        createNewChatSession()
                    }) {
                        Image(systemName: "square.and.pencil")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.black)
                            .padding(.trailing, 16)
                    }
                }

                // Chat Messages or Empty State
                if let sessionId = selectedSessionId {
                    ChatSessionView(sessionId: String(sessionId))
                } else {
                    VStack {
                        Text("No Chat Selected")
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    }
                }

                // Message input field and send button
                HStack {
                    TextField("Type a message...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 16)

                    Button(action: {
                        sendMessage()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.red)
                            .padding(.trailing, 16)
                    }
                }
                .padding(.bottom, 40)
            }
            .edgesIgnoringSafeArea(.horizontal)
            .edgesIgnoringSafeArea(.bottom)
            .onAppear {
                fetchChatSessions()
            }
            .sheet(isPresented: $isRenameSheetOpen) {
                VStack {
                    Text("Rename Chat Session")
                        .font(.headline)
                        .padding()

                    TextField("New Title", text: $newSessionTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    HStack {
                        Button("Cancel") {
                            isRenameSheetOpen = false
                        }
                        .padding()

                        Button("Save") {
                            if let sessionId = selectedSessionId {
                                renameChatSession(sessionId: sessionId, newTitle: newSessionTitle)
                            }
                            isRenameSheetOpen = false
                        }
                        .padding()
                    }
                }
                .padding()
            }
        }
    }

    private func fetchChatSessions() {
        NetworkManager.shared.getChatSessions(userToken: userToken) { result in
            switch result {
            case .success(let sessions):
                DispatchQueue.main.async {
                    self.chatSessions = sessions
                    if self.selectedSessionId == nil, let firstSession = sessions.first {
                        self.selectedSessionId = firstSession.id
                    }
                }
            case .failure(let error):
                print("Failed to fetch chat sessions: \(error.localizedDescription)")
            }
        }
    }

    private func renameChatSession(sessionId: Int, newTitle: String) {
        NetworkManager.shared.updateChatSession(sessionId: String(sessionId), title: newTitle, userToken: userToken) { success in
            if success {
                if let index = self.chatSessions.firstIndex(where: { $0.id == sessionId }) {
                    self.chatSessions[index].title = newTitle
                }
            } else {
                print("Failed to rename chat session.")
            }
        }
    }

    private func createNewChatSession() {
        NetworkManager.shared.createChatSession(userToken: userToken) { result in
            switch result {
            case .success(let sessionId):
                self.selectedSessionId = sessionId
                self.fetchChatSessions()
            case .failure(let error):
                print("Failed to create chat session: \(error.localizedDescription)")
            }
        }
    }

    private func sendMessage() {
        guard let sessionId = selectedSessionId, !messageText.isEmpty else { return }

        let newMessage = Message(id: UUID().hashValue, content: messageText, isFromCurrentUser: true, createdAt: Date().timeIntervalSince1970)

        NetworkManager.shared.storeMessage(in: String(sessionId), content: messageText, userToken: userToken) { success in
            if success {
                DispatchQueue.main.async {
                    self.messages.append(newMessage)
                    self.messageText = ""
                }
            } else {
                print("Failed to send message.")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
