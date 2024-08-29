// LoginView.swift
// Version 2.0.0

import SwiftUI
import Combine

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @AppStorage("userToken") var userToken: String = ""
    @AppStorage("userEmail") var userEmail: String = ""
    @AppStorage("userId") var userId: Int = 0 // Store userId as an Int
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        VStack {
            Spacer()

            // App Logo and Slogan
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100) // Adjust size as needed
            Text("CMO in your pocket")
                .font(.subheadline
                      .bold())
                .foregroundColor(.black)

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
                    .background(.black)
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

        NetworkManager.shared.loginUser(email: email, password: password)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    errorMessage = "Login failed: \(error.localizedDescription)"
                    showError = true
                }
            }, receiveValue: { (token, id) in
                userToken = token
                userEmail = email
                userId = id
                showError = false
                print("Login successful. User ID: \(id), Token: \(token)")
                // Proceed to the next screen or update the UI as needed
            })
            .store(in: &cancellables)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
