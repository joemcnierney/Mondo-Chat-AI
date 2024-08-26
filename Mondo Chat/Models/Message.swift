// Message.swift
// Version 1.1.2

import Foundation
import SwiftUI

struct Message: Identifiable, Decodable {
    let id: Int
    let content: String
    let isFromCurrentUser: Bool
    let createdAt: TimeInterval?

    enum CodingKeys: String, CodingKey {
        case id
        case content
        case userId = "user_id"
        case isAI = "is_ai"
        case createdAt = "created_at"
    }

    // Custom decoding to determine `isFromCurrentUser`
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        createdAt = try container.decode(TimeInterval.self, forKey: .createdAt)
        
        // Decoding userId and isAI from the JSON
        let messageUserId = try container.decode(Int.self, forKey: .userId)
        let isAI = try container.decode(Bool.self, forKey: .isAI)

        // Access the current user's ID stored locally via AppStorage
        let currentUserId = UserDefaults.standard.integer(forKey: "userId")

        // Set isFromCurrentUser based on comparison
        isFromCurrentUser = (messageUserId == currentUserId) && !isAI
    }
}
