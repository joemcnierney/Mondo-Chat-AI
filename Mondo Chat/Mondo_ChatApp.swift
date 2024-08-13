// Mondo_ChatApp.swift
// Version 1.2.0

import SwiftUI

@main
struct Mondo_ChatApp: App {
    @AppStorage("userToken") var userToken: String = ""

    var body: some Scene {
        WindowGroup {
            if userToken.isEmpty {
                LoginView()
            } else {
                ContentView()
            }
        }
    }
}
