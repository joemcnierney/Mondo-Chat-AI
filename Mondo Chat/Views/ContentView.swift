// ContentView.swift
// Version 1.2.0

import SwiftUI
import Combine

struct ContentView: View {
    @State private var selectedSessionId: Int? = nil
    @State private var chatSessions: [ChatSession] = []
    @State private var isMenuOpen: Bool = false
    @State private var messageText: String = ""
    @State private var messages: [Message] = []
    @State private var showRenameAlert: Bool = false
    @AppStorage("userToken") var userToken: String = ""

    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Top bar with menu icon and create session button
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

                // Chat sessions and messages view
                if let selectedSessionId = selectedSessionId {
                    ChatSessionView(sessionId: String(selectedSessionId))
                        .padding(.bottom, 50)  // Ensure there's space for the message box
                } else {
                    Text("Select or create a chat session")
                        .foregroundColor(.gray)
                        .padding()
                }

                // Message input field and send button, docked at the bottom
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
                .background(Color(.systemGray6))
                .frame(width: geometry.size.width, height: 50, alignment: .center)
                .padding(.bottom)
            }
            .sheet(isPresented: $isMenuOpen) {
                MenuView(chatSessions: $chatSessions, selectedSessionId: $selectedSessionId)
                    .transition(.move(edge: .leading))
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
        NetworkManager.shared.sendMessage(userToken: userToken, sessionId: sessionId, message: newMessage) { result in
            switch result {
            case .success(_):
                print("Message sent successfully.")
                messages.append(newMessage)
            case .failure(let error):
                print("Failed to send message: \(error.localizedDescription)")
            }
        }

        messageText = ""
    }

    private func createNewChatSession() {
        // Implement the function to create a new chat session
    }

    private func renameSession() {
        // Implement the function to rename the selected chat session
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
