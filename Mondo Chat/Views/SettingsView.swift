// SettingsView.swift
// Version 1.1.0

import SwiftUI

struct SettingsView: View {
    @AppStorage("userToken") var userToken: String = ""
    @AppStorage("userEmail") var userEmail: String = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        Form {
            Section(header: Text("Account")) {
                HStack {
                    Text("Email")
                    Spacer()
                    Text(userEmail)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Button(action: restorePurchases) {
                    Text("Restore Purchases")
                }
            }
            
            Section(header: Text("Preferences")) {
                Toggle(isOn: .constant(true)) {
                    Text("Receive Notifications")
                }
                // Add more preference toggles as needed
            }
            
            Section {
                Button(action: signOut) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Settings")
    }

    private func restorePurchases() {
        // Implement restore purchases functionality
    }

    private func signOut() {
        userToken = ""
        presentationMode.wrappedValue.dismiss()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
