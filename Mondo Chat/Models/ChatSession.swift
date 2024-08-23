// ChatSession.swift
// Version 1.0.0

import Foundation

struct ChatSession: Identifiable, Decodable {
    let id: Int
    var title: String
    let createdAt: TimeInterval?
    let updatedAt: TimeInterval?

    enum CodingKeys: String, CodingKey {
        case id
        case title = "session_title"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
