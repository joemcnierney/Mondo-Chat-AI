// MenuView.swift
// Version 1.1.0

import SwiftUI

struct MenuView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Chat Sessions")) {
                    // Placeholder for chat session items
                    Text("Session 1")
                    Text("Session 2")
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
    static var previews: some View {
        MenuView()
    }
}
