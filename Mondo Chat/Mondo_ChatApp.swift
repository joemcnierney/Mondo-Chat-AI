// Mondo_ChatApp.swift
// Version 0.1.1

import SwiftUI

@main
struct Mondo_ChatApp: App {
    @AppStorage("userToken") var userToken: String = ""

    var body: some Scene {
        WindowGroup {
            if userToken.isEmpty {
                LoginView()
            } else {
                ContentView()  // ContentView will manage the ChatSessionView as its initial view
            }
        }
    }
}
