//
//  FriendRequest.swift
//  AudioAudit
//

import Foundation
import FirebaseFirestore

struct FriendRequest: Codable, Identifiable {
    @DocumentID var id: String?
    var fromUid: String
    var toUid: String
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case fromUid = "from_uid"
        case toUid = "to_uid"
        case createdAt = "created_at"
    }
}
