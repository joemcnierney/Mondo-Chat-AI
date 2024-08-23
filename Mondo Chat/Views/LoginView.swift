// LoginView.swift
// Version 1.2.0

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @AppStorage("userToken") var userToken: String = ""
    @AppStorage("userEmail") var userEmail: String = ""

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
                .autocapitalization(.none)
                .disableAutocorrection(true)

            // Password Field
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Error Message
            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            // Login Button
            Button(action: login) {
                Text("Login")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            Spacer()
        }
        .padding()
    }

    private func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            showError = true
            return
        }

        NetworkManager.shared.loginUser(email: email, password: password) { result in
            switch result {
            case .success(let token):
                userToken = token
                userEmail = email
                showError = false
            case .failure(let error):
                errorMessage = "Login failed: \(error.localizedDescription)"
                showError = true
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}