import SwiftUI

struct ChatSessionView: View {
    var sessionId: Int
    @State private var messages: [Message] = []
    @AppStorage("userToken") var userToken: String = ""
    @AppStorage("userId") var userId: Int = 0 // Ensure userId is stored as an Int

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
                        } else {
                            Text(message.content)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                                .foregroundColor(.black)
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .onAppear {
                fetchMessages(for: sessionId)
            }
        }
    }

    private func fetchMessages(for sessionId: Int) {
        NetworkManager.shared.fetchMessages(userToken: userToken, sessionId: sessionId, userId: userId) { result in
            switch result {
            case .success(let fetchedMessages):
                self.messages = fetchedMessages
            case .failure(let error):
                print("Failed to fetch messages: \(error.localizedDescription)")
            }
        }
    }
}

struct ChatSessionView_Previews: PreviewProvider {
    static var previews: some View {
        ChatSessionView(sessionId: 1)
    }
}
