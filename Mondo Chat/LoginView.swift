// LoginView.swift
// Version 1.1.0

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @AppStorage("userToken") var userToken: String = ""

    var body: some View {
        VStack {
            Spacer()

            // App Logo and Slogan
            Text("mon·do")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("CMO in your pocket")
                .font(.subheadline)
                .foregroundColor(.gray)

            Spacer()

            // Email Field
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Password Field
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Login Button
            Button(action: {
                login()
            }) {
                Text("Log In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding()
            }

            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Spacer()
        }
        .padding()
    }

    private func login() {
        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:uoSb7QpQ/auth/login") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Login request failed: \(error.localizedDescription)")
                showError(message: "Login failed. Please try again.")
                return
            }

            guard let data = data else {
                print("No data received")
                showError(message: "No response from server.")
                return
            }

            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let token = jsonResponse["authToken"] as? String {
                DispatchQueue.main.async {
                    self.userToken = token
                    // Navigate to the main content view
                    // This could be done by setting a @State variable that controls the view flow
                }
            } else {
                print("Failed to parse JSON response")
                showError(message: "Invalid credentials. Please try again.")
            }
        }.resume()
    }

    private func showError(message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.showError = true
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
