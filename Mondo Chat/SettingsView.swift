//  SettingsView.swift
//  Version: 1.0.0

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Form {
                // Account Section
                Section(header: Text("ACCOUNT")) {
                    NavigationLink(destination: PlaceholderView(title: "Email")) {
                        Label("Email", systemImage: "envelope")
                    }
                    NavigationLink(destination: PlaceholderView(title: "Subscription")) {
                        Label("Subscription", systemImage: "plus.circle")
                    }
                    NavigationLink(destination: PlaceholderView(title: "Restore purchases")) {
                        Label("Restore purchases", systemImage: "arrow.clockwise")
                    }
                    NavigationLink(destination: PlaceholderView(title: "Data Controls")) {
                        Label("Data Controls", systemImage: "slider.horizontal.3")
                    }
                    NavigationLink(destination: PlaceholderView(title: "Custom Instructions")) {
                        Label("Custom Instructions", systemImage: "bubble.left.and.bubble.right")
                    }
                }
                
                // App Section
                Section(header: Text("APP")) {
                    NavigationLink(destination: PlaceholderView(title: "Color Scheme")) {
                        Label("Color Scheme", systemImage: "paintbrush")
                    }
                    Toggle(isOn: .constant(true)) {
                        Label("Haptic Feedback", systemImage: "waveform.path")
                    }
                    Text("Haptic feedback will be automatically disabled if your device is low on battery.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                
                // Speech Section
                Section(header: Text("SPEECH")) {
                    NavigationLink(destination: PlaceholderView(title: "Main Language")) {
                        Label("Main Language", systemImage: "globe")
                    }
                    Text("For best results, select the language you mainly speak.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                
                // About Section
                Section(header: Text("ABOUT")) {
                    NavigationLink(destination: PlaceholderView(title: "Help Center")) {
                        Label("Help Center", systemImage: "questionmark.circle")
                    }
                    NavigationLink(destination: PlaceholderView(title: "Terms of Use")) {
                        Label("Terms of Use", systemImage: "doc.text")
                    }
                    NavigationLink(destination: PlaceholderView(title: "Privacy Policy")) {
                        Label("Privacy Policy", systemImage: "lock")
                    }
                    NavigationLink(destination: PlaceholderView(title: "Licenses")) {
                        Label("Licenses", systemImage: "book.closed")
                    }
                    Text("Mondo Chat App for iOS 1.0")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                
                // Sign Out
                Section {
                    Button(action: {
                        // Sign out logic
                    }) {
                        Text("Sign out")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
        }
    }
}

struct PlaceholderView: View {
    let title: String
    var body: some View {
        Text("\(title) Placeholder")
            .font(.largeTitle)
            .foregroundColor(.gray)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
