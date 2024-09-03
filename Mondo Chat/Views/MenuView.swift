// MenuView.swift
// Version 2.1.3

import SwiftUI

struct MenuView: View {
    @Binding var chatSessions: [ChatSession]
    @Binding var selectedSessionId: Int?
    var onSessionSelected: (Int) -> Void

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Chat Sessions")) {
                    ForEach(chatSessions) { session in
                        Button(action: {
                            selectedSessionId = session.id
                            onSessionSelected(session.id)
                        }) {
                            HStack {
                                Text(session.title)
                                Spacer()
                                if session.id == selectedSessionId {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }

                Section(header: Text("Account")) {
                    NavigationLink(destination: SettingsView()) {
                        Text("Settings")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Menu")
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    @State static var chatSessions = [ChatSession(id: 1, title: "Session 1", createdAt: nil, updatedAt: nil)]
    @State static var selectedSessionId: Int? = 1

    static var previews: some View {
        MenuView(chatSessions: $chatSessions, selectedSessionId: $selectedSessionId, onSessionSelected: { _ in })
    }
}
