//
//  Interaction.swift
//  AudioAudit
//
//  Created by Bersam Basagaoglu on 4/26/26.
//

import Foundation
import FirebaseFirestore

enum InteractionType: String, Codable {
    case like
    case dislike
    case comment
}

struct Interaction: Codable, Identifiable {
    @DocumentID var id: String?
    var activityId: String
    var userId: String
    var type: InteractionType
    var text: String?
    var timestamp: Date

    enum CodingKeys: String, CodingKey {
        case id
        case activityId = "activity_id"
        case userId = "user_id"
        case type
        case text
        case timestamp
    }
}
