// ContentView.swift
// Version 1.1.0

import SwiftUI
import Combine

struct ContentView: View {
    @State private var messageText: String = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var isMenuOpen: Bool = false
    @State private var chatSessionId: String?
    @State private var messages: [Message] = []
    @AppStorage("userToken") var userToken: String = ""

    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Top bar with menu icon and edit icon
                HStack {
                    // Menu Icon (Placeholder)
                    Button(action: {
                        isMenuOpen.toggle()
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.black)  // Set icon color to black
                            .padding(.leading, 16)
                            
                    }
                    .sheet(isPresented: $isMenuOpen) {
                        MenuView()
                    }
                    
                    Spacer()
                    
                    // Chat Session Title
                    Text(chatSessionId != nil ? "Session \(chatSessionId!)" : "New Chat")
                        .font(.headline)
                        .contextMenu {
                            Button(action: {
                                // Placeholder for rename functionality
                                renameChatSession()
                            }) {
                                Text("Rename")
                                Image(systemName: "pencil")
                            }
                        }

                    Spacer()

                    // Edit Icon
                    Image(systemName: "square.and.pencil")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                        .padding(.trailing, 16)
                        .onTapGesture {
                            // Placeholder for new chat session creation
                            createNewChatSession()
                        }
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
            .edgesIgnoringSafeArea(.horizontal) // Adjusts for safe areas except top and bottom
            .edgesIgnoringSafeArea(.bottom) // Adjusts for safe areas except top and bottom
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
            NetworkManager.shared.storeMessage(in: sessionId, content: messageText, userToken: userToken) { success in
                if success {
                    DispatchQueue.main.async {
                        self.messages.append(Message(text: self.messageText, isFromCurrentUser: true))
                        self.messageText = "" // Clear the input field after sending
                    }
                } else {
                    print("Failed to store message.")
                }
            }
        } else {
            print("No Session ID, creating new chat session.")
            NetworkManager.shared.createChatSession(userToken: userToken) { result in
                switch result {
                case .success(let sessionId):
                    self.chatSessionId = String(sessionId)
                    NetworkManager.shared.storeMessage(in: String(sessionId), content: self.messageText, userToken: self.userToken) { success in
                        if success {
                            DispatchQueue.main.async {
                                self.messages.append(Message(text: self.messageText, isFromCurrentUser: true))
                                self.messageText = "" // Clear the input field after sending
                            }
                        } else {
                            print("Failed to store message.")
                        }
                    }
                case .failure(let error):
                    print("Failed to create chat session: \(error.localizedDescription)")
                }
            }
        }
    }

    private func renameChatSession() {
        guard let sessionId = chatSessionId else { return }

        let newTitle = "Renamed Chat" // Replace this with actual input for the new title
        NetworkManager.shared.updateChatSession(sessionId: sessionId, title: newTitle, userToken: userToken) { success in
            if success {
                self.chatSessionId = newTitle
            } else {
                print("Failed to rename chat session.")
            }
        }
    }

    private func createNewChatSession() {
        NetworkManager.shared.createChatSession(userToken: userToken) { result in
            switch result {
            case .success(let sessionId):
                self.chatSessionId = String(sessionId)
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
