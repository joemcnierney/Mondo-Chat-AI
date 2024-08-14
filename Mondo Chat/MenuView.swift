// MenuView.swift
// Version 0.0.2

import SwiftUI

struct MenuView: View {
    @Binding var chatSessions: [ChatSession]
    @Binding var selectedSessionId: Int?

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Chat Sessions")) {
                    ForEach(chatSessions) { session in
                        Button(action: {
                            selectedSessionId = session.id
                        }) {
                            HStack {
                                Text(session.title)
                                Spacer()
                                if session.id == selectedSessionId {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }

                Section(header: Text("Account")) {
                    NavigationLink(destination: SettingsView()) {
                        HStack {
                            Image(systemName: "person.circle")
                            Text("Account Settings")
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Menu")
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    @State static var chatSessions: [ChatSession] = [
        ChatSession(id: 1, title: "Session 1", createdAt: nil, updatedAt: nil),
        ChatSession(id: 2, title: "Session 2", createdAt: nil, updatedAt: nil)
    ]
    @State static var selectedSessionId: Int? = 1

    static var previews: some View {
        MenuView(chatSessions: $chatSessions, selectedSessionId: $selectedSessionId)
    }
}
