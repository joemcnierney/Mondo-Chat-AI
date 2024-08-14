// ChatSession.swift
// Version 0.1.0

import Foundation

struct ChatSession: Identifiable, Decodable {
    let id: Int
    var title: String  // Make title mutable
    let createdAt: TimeInterval?
    let updatedAt: TimeInterval?

    enum CodingKeys: String, CodingKey {
        case id
        case title = "session_title"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
