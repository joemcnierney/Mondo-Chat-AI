// SignUpView.swift
// Version 2.0.0

import SwiftUI
import Combine

struct SignUpView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @AppStorage("userToken") var userToken: String = ""
    @AppStorage("userId") var userId: Int = 0 // Store userId as an Int
    @State private var cancellables = Set<AnyCancellable>()

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

            // Name Field
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

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

            // Sign-Up Button
            Button(action: signUp) {
                Text("Sign Up")
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

    private func signUp() {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            showError = true
            return
        }

        NetworkManager.shared.signUpUser(name: name, email: email, password: password)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    errorMessage = "Sign-up failed: \(error.localizedDescription)"
                    showError = true
                }
            }, receiveValue: { (token, id) in
                userToken = token
                userId = id
                showError = false
                print("Sign-up successful. User ID: \(id), Token: \(token)")
                // Proceed to the next screen or update the UI as needed
            })
            .store(in: &cancellables)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
