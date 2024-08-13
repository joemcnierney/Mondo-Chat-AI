//  MenuView.swift
//  Version: 1.0.0

import SwiftUI

struct MenuView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Top section with New Chat
                HStack {
                    Image(systemName: "square.and.pencil")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(.leading, 16)
                    
                    Text("New Chat")
                        .font(.headline)
                        .padding(.leading, 8)
                }
                .padding(.top, 40)
                
                Divider().padding(.vertical, 10)
                
                // List of chats (placeholders)
                List {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Website Edits")
                                .font(.headline)
                            Text("Service: Web Design")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("Detail")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("New Pamphlet Design")
                                .font(.headline)
                            Text("Service: Graphic Design")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("Detail")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("New Blog Entry")
                                .font(.headline)
                            Text("Service: Web Design")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("Detail")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Facebook Posts - November")
                                .font(.headline)
                            Text("Service: Social Media")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("Detail")
                            .foregroundColor(.gray)
                    }
                }
                .listStyle(PlainListStyle())
                
                Spacer()
                
                // Bottom section with account
                NavigationLink(destination: SettingsView()) {
                    HStack {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .padding(.leading, 16)
                        
                        Text("Account")
                            .font(.headline)
                            .padding(.leading, 8)
                    }                }
                
                .padding(.bottom, 30)
            }
            .navigationBarHidden(true)
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
