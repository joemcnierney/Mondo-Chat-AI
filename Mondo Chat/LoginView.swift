//  LoginView.swift
//  Version: 1.0.0

import SwiftUI

struct LoginView: View {
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
            
            // Login Button
            Button(action: {
                loginUser()
            }) {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .disabled(isLoading)
            
            Spacer()
            
            // Sign-up Navigation
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.white)
                Button(action: {
                    // Navigate to signup view (to be implemented)
                }) {
                    Text("Sign up")
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    // MARK: - Login Function
    private func loginUser() {
        guard !email.isEmpty, !password.isEmpty

 else {
            errorMessage = "Please enter both email and password."
            return
        }

        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "https://x8ki-letl-twmt.n7.xano.io/api:uoSb7QpQ/auth/login") else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["email": email, "password": password]
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
                
                // Debug: Print the raw data received
                if let rawResponse = String(data: data, encoding: .utf8) {
                    print("Raw response: \(rawResponse)")
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    self.errorMessage = "Login failed with status code: \(httpResponse.statusCode)"
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

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
