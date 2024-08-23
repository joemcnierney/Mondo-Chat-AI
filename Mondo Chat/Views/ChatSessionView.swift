// ChatSessionView.swift
// Version 1.2.0

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
        }
        .onAppear {
            fetchMessages()
        }
    }

    private func fetchMessages() {
        guard let sessionIdInt = Int(sessionId) else { return }
        
        NetworkManager.shared.fetchMessages(userToken: userToken, sessionId: sessionIdInt) { result in
            switch result {
            case .success(let fetchedMessages):
                messages = fetchedMessages
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
