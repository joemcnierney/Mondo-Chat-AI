// SignUpView.swift
// Version 1.1.0

import SwiftUI

struct SignUpView: View {
    @State private var name: String = ""
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
        // Implement the sign-up function
        // Handle user registration and manage errors, updating showError and errorMessage as needed
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
