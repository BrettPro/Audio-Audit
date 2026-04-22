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

    // The cached current user. Set after login, register, or app launch.
    var currentUser: AAUser?

    // Returns the current Firebase Auth user ID, or nil if not signed in.
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    // Fetches the current user from Firestore and caches it.
    func loadCurrentUser() async throws {
        currentUser = try await fetchCurrentUser()
    }

    // Clears the cached current user (logout)
    func clearCurrentUser() {
        currentUser = nil
    }

    // Create a new user document using the Firebase Auth UID as the document ID.
    func createUser(uid: String, name: String, email: String) async throws {
        let user = AAUser(
            name: name,
            email: email,
            profilePicURL: DEFAULT_PFP,
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

    // Case-insensitive substring search over all users (test-app scale).
    func searchUsers(byNamePrefix query: String, limit: Int = 50) async throws -> [AAUser] {
        guard !query.isEmpty else { return [] }
        let all = try await store.fetchAll(type: AAUser.self, collection: collection, filter: nil)
        return all
            .filter { $0.name.localizedCaseInsensitiveContains(query) }
            .prefix(limit)
            .map { $0 }
    }

    // Fetch all friends of a user.
    func fetchFriends(of uid: String) async throws -> [AAUser] {
        let user = try await fetchUser(uid: uid)
        return try await fetchUsers(uids: user.friends).values.map { $0 }
    }

    // Fetch a batch of users by UID. Chunked due to Firestore `in` query 30-item limit.
    func fetchUsers(uids: [String]) async throws -> [String: AAUser] {
        if uids.isEmpty { return [:] }
        var result: [String: AAUser] = [:]
        for chunk in uids.chunked(into: 30) {
            let users = try await store.fetchAll(type: AAUser.self, collection: collection, filter: { ref in
                ref.whereField(FieldPath.documentID(), in: chunk)
            })
            for user in users {
                if let id = user.id {
                    result[id] = user
                }
            }
        }
        return result
    }
    
    func updateProfileSong(
        uid: String,
        title: String,
        artist: String,
        previewURL: String?
    ) async throws {
        try await store.update(
            collection: collection,
            documentId: uid,
            fields: [
                "profile_song_title": title,
                "profile_song_artist": artist,
                "profile_song_preview_url": previewURL ?? ""
            ]
        )
    }
}
