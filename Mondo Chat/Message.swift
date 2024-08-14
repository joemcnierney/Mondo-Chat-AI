// Message.swift
// Version 0.1.1

import Foundation

struct Message: Identifiable, Decodable {
    let id: Int
    let content: String
    let isFromCurrentUser: Bool
    let createdAt: TimeInterval?

    enum CodingKeys: String, CodingKey {
        case id
        case content
        case isFromCurrentUser = "is_from_current_user"
        case createdAt = "created_at"
    }
}
