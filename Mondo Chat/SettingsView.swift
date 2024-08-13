// SettingsView.swift
// Version 1.1.0

import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("Account")) {
                Text("Email")
                Text("Subscription")
                Button(action: {
                    // Placeholder for restore purchases action
                }) {
                    Text("Restore Purchases")
                }
            }
            
            Section(header: Text("Preferences")) {
                Toggle(isOn: .constant(true)) {
                    Text("Haptic Feedback")
                }
                Toggle(isOn: .constant(false)) {
                    Text("Dark Mode")
                }
                Picker("Main Language", selection: .constant(1)) {
                    Text("English").tag(1)
                    Text("Spanish").tag(2)
                }
            }
            
            Section(header: Text("Support")) {
                NavigationLink(destination: Text("Help Center Placeholder")) {
                    Text("Help Center")
                }
                NavigationLink(destination: Text("Terms of Use Placeholder")) {
                    Text("Terms of Use")
                }
                NavigationLink(destination: Text("Privacy Policy Placeholder")) {
                    Text("Privacy Policy")
                }
                NavigationLink(destination: Text("Licenses Placeholder")) {
                    Text("Licenses")
                }
            }
            
            Section {
                Button(action: {
                    // Placeholder for sign out action
                }) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationBarTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
