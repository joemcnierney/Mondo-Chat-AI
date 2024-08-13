//  SignUpView.swift
//  Version: 1.0.0

import SwiftUI

struct SignUpView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("userToken") var userToken: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // App Logo
            Text("mon·do")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // App Slogan
            Text("CMO in your pocket")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            // Name Field
            TextField("Name", text: $name)
                .autocapitalization(.words)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(.white)
            
            // Email Field
            TextField("Email", text: $email)
                .autocapitalization(.none)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(.white)
            
            // Password Field
            SecureField("Password", text: $password)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(.white)
            
            // Error Message
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            // Sign-Up Button
            Button(action: {
                signUpUser()
            }) {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .disabled(isLoading)
            
            Spacer()
            
            // Login Navigation
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.white)
                Button(action: {
                    // Navigate back to login view
                }) {
                    Text("Login")
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    // MARK: - Sign-Up Function
    private func signUpUser() {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill out all fields."
            return
        }

        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:uoSb7QpQ/auth/signup") else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["name": name, "email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data in response"
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    self.errorMessage = "Sign up failed with status code: \(httpResponse.statusCode)"
                    return
                }

                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let token = jsonResponse["authToken"] as? String {
                        self.userToken = token
                        self.isLoggedIn = true
                    } else {
                        self.errorMessage = "authToken not found in response"
                    }
                } catch {
                    self.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
