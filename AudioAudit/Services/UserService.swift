//
//  UserService.swift
//  AudioAudit
//
//  Created by Bersam Basagaoglu on 3/9/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserService {

    static let shared = UserService()
    private let store = FirestoreService.shared
    private let collection = "users"

    private init() {}


    // Returns the current Firebase Auth user ID, or nil if not signed in.
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }


    // Create a new user document using the Firebase Auth UID as the document ID.
    func createUser(uid: String, name: String, email: String) async throws {
        let user = AAUser(
            name: name,
            email: email,
            profilePicURL: nil,
            friends: [],
            createdAt: Date(),
            lastLogin: Date(),
            spotifyCredential: nil
        )
        try await store.set(object: user, collection: collection, documentId: uid)
    }

    // Fetch a user by their UID.
    func fetchUser(uid: String) async throws -> AAUser {
        try await store.fetch(type: AAUser.self, collection: collection, documentId: uid)
    }

    // Fetch the currently signed-in user.
    func fetchCurrentUser() async throws -> AAUser {
        guard let uid = currentUserId else {
            throw NSError(domain: "UserService", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user signed in."])
        }
        return try await fetchUser(uid: uid)
    }

    // Update the last login timestamp to now.
    func updateLastLogin(uid: String) async throws {
        try await store.update(collection: collection, documentId: uid, fields: [
            "last_login": Timestamp(date: Date())
        ])
    }

    // Update profile picture URL.
    func updateProfilePic(uid: String, url: String) async throws {
        try await store.update(collection: collection, documentId: uid, fields: [
            "profile_pic_url": url
        ])
    }


    // Add a friend by appending their UID to the friends array.
    func addFriend(uid: String, friendId: String) async throws {
        try await store.update(collection: collection, documentId: uid, fields: [
            "friends": FieldValue.arrayUnion([friendId])
        ])
    }

    // Remove a friend by removing their UID from the friends array.
    func removeFriend(uid: String, friendId: String) async throws {
        try await store.update(collection: collection, documentId: uid, fields: [
            "friends": FieldValue.arrayRemove([friendId])
        ])
    }


    // Save or update Spotify credentials.
    func updateSpotifyCredential(uid: String, credential: SpotifyCredential) async throws {
        try await store.update(collection: collection, documentId: uid, fields: [
            "spotify_credential": [
                "access_token": credential.accessToken,
                "refresh_token": credential.refreshToken,
                "expires_at": Timestamp(date: credential.expiresAt)
            ]
        ])
    }

    // Delete the user document.
    func deleteUser(uid: String) async throws {
        try await store.delete(collection: collection, documentId: uid)
    }
}
