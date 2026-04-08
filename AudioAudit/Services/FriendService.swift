//
//  FriendService.swift
//  AudioAudit
//

import Foundation
import FirebaseFirestore

class FriendService {

    static let shared = FriendService()
    private let store = FirestoreService.shared
    private let collection = "friend_requests"

    private init() {}

    private func docId(from: String, to: String) -> String {
        return "\(from)_\(to)"
    }

    // Send a friend request from `from` to `to`.
    func sendRequest(from: String, to: String) async throws {
        let request = FriendRequest(
            fromUid: from,
            toUid: to,
            createdAt: Date()
        )
        try await store.set(object: request, collection: collection, documentId: docId(from: from, to: to))
    }

    // Cancel a sent request.
    func cancelRequest(from: String, to: String) async throws {
        try await store.delete(collection: collection, documentId: docId(from: from, to: to))
    }

    // Deny an incoming request.
    func denyRequest(from: String, to: String) async throws {
        try await store.delete(collection: collection, documentId: docId(from: from, to: to))
    }

    // Accept an incoming request: mutual arrayUnion into both users' `friends`,
    // then delete the request document.
    func acceptRequest(from: String, to: String) async throws {
        try await UserService.shared.addFriend(uid: to, friendId: from)
        try await UserService.shared.addFriend(uid: from, friendId: to)
        try await store.delete(collection: collection, documentId: docId(from: from, to: to))
    }

    // Fetch incoming requests for a user. Sorted client-side to avoid
    // requiring a Firestore composite index.
    func fetchIncomingRequests(for uid: String) async throws -> [FriendRequest] {
        let results = try await store.fetchAll(type: FriendRequest.self, collection: collection, filter: { ref in
            ref.whereField("to_uid", isEqualTo: uid)
        })
        return results.sorted { $0.createdAt > $1.createdAt }
    }

    // Fetch outgoing requests for a user. Sorted client-side.
    func fetchOutgoingRequests(for uid: String) async throws -> [FriendRequest] {
        let results = try await store.fetchAll(type: FriendRequest.self, collection: collection, filter: { ref in
            ref.whereField("from_uid", isEqualTo: uid)
        })
        return results.sorted { $0.createdAt > $1.createdAt }
    }
}
