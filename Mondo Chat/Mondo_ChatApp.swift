//
//  Mondo_ChatApp.swift
//  Mondo Chat
//
//  Created by Joe McNierney on 8/9/24.
//

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

