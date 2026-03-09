//
//  MapPin.swift
//  AudioAudit
//
//  Created by Bersam Basagaoglu on 3/9/26.
//

import Foundation
import FirebaseFirestore

struct MapPin: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var song: String
    var artist: String
    var latitude: Double
    var longitude: Double
    var timestamp: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case song
        case artist
        case latitude
        case longitude
        case timestamp
    }
}
