//  Mondo_ChatApp.swift
//  Version: 1.0.0

import SwiftUI

@main
struct Mondo_ChatApp: App {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                ContentView()
            } else {
                LoginView()
            }
        }
    }
}

