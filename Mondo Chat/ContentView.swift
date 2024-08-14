// ContentView.swift
// Version 0.1.2

import SwiftUI
import Combine

struct ContentView: View {
    @State private var selectedSessionId: Int?
    @State private var chatSessions: [ChatSession] = []
    @State private var isMenuOpen: Bool = false
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
                            .contextMenu {
                                Button(action: {
                                    // Placeholder for rename functionality
                                    renameChatSession(session: session)
                                }) {
                                    Text("Rename")
                                    Image(systemName: "pencil")
                                }
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
            }
            .edgesIgnoringSafeArea(.horizontal)
            .edgesIgnoringSafeArea(.bottom)
            .onAppear {
                fetchChatSessions()
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

    private func renameChatSession(session: ChatSession) {
        let newTitle = "Renamed Chat"
        NetworkManager.shared.updateChatSession(sessionId: String(session.id), title: newTitle, userToken: userToken) { success in
            if success {
                if let index = self.chatSessions.firstIndex(where: { $0.id == session.id }) {
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
