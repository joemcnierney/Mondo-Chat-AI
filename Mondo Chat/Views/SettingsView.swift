// SettingsView.swift
// Version 1.2.1

import SwiftUI

struct SettingsView: View {
    @AppStorage("userToken") var userToken: String = ""
    @AppStorage("userEmail") var userEmail: String = ""
    @AppStorage("userId") var userId: Int = 0 // Store userId as an Int
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
        userEmail = ""
        userId = 0  // Clear the userId as well
        presentationMode.wrappedValue.dismiss()
        print("User signed out successfully")
        // Additional logic to navigate back to login screen if needed
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
