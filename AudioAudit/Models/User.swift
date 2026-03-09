//
//  User.swift
//  AudioAudit
//
//  Created by Bersam Basagaoglu on 3/9/26.
//

import Foundation
import FirebaseFirestore

struct SpotifyCredential: Codable {
    var accessToken: String
    var refreshToken: String
    var expiresAt: Date

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAt = "expires_at"
    }
}

struct AAUser: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var email: String
    var profilePicURL: String?
    var friends: [String]
    var createdAt: Date
    var lastLogin: Date
    var spotifyCredential: SpotifyCredential?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case profilePicURL = "profile_pic_url"
        case friends
        case createdAt = "created_at"
        case lastLogin = "last_login"
        case spotifyCredential = "spotify_credential"
    }
}
