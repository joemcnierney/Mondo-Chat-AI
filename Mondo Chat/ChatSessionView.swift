// ChatSessionView.swift
// Version 0.1.2

import SwiftUI

struct ChatSessionView: View {
    var sessionId: String
    @State private var messages: [Message] = []
    @AppStorage("userToken") var userToken: String = ""

    var body: some View {
        VStack {
            ScrollView {
                ForEach(messages) { message in
                    HStack {
                        if message.isFromCurrentUser {
                            Spacer()
                            Text(message.content)  // Updated to use the 'content' property of Message
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        } else {
                            Text(message.content)  // Updated to use the 'content' property of Message
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                }
            }
            .onAppear {
                fetchMessages()
            }

            Spacer()

            // Placeholder for message input field and send button
            TextField("Type a message...", text: .constant(""))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
        }
        .navigationBarTitle("Chat", displayMode: .inline)
    }

    private func fetchMessages() {
        NetworkManager.shared.getMessages(for: sessionId, userToken: userToken) { result in
            switch result {
            case .success(let fetchedMessages):
                DispatchQueue.main.async {
                    self.messages = fetchedMessages
                }
            case .failure(let error):
                print("Failed to fetch messages: \(error.localizedDescription)")
            }
        }
    }
}

struct ChatSessionView_Previews: PreviewProvider {
    static var previews: some View {
        ChatSessionView(sessionId: "1")
    }
}
