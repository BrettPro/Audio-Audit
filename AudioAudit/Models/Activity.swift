//
//  Activity.swift
//  AudioAudit
//
//  Created by Bersam Basagaoglu on 3/9/26.
//

import Foundation
import FirebaseFirestore

enum ActivityType: String, Codable {
    case review
    case listen
}

struct Activity: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var type: ActivityType
    var song: String
    var artist: String
    var rating: Int?
    var review: String?
    var timestamp: Date
    var latitude: Double?
    var longitude: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case type
        case song
        case artist
        case rating
        case review
        case timestamp
        case latitude
        case longitude
    }
}
