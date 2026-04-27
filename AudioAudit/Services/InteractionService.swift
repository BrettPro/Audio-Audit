//
//  InteractionService.swift
//  AudioAudit
//
//  Created by Bersam Basagaoglu on 4/26/26.
//

import Foundation
import FirebaseFirestore

class InteractionService {

    static let shared = InteractionService()
    private let store = FirestoreService.shared
    private let collection = "interactions"

    private init() {}

    // Deterministic id so re-liking or switching like<->dislike replaces the same doc.
    private func reactionId(userId: String, activityId: String) -> String {
        return "\(userId)_\(activityId)"
    }

    // Set or replace a user's like/dislike on an activity.
    func setReaction(type: InteractionType, userId: String, activityId: String) async throws {
        let interaction = Interaction(
            activityId: activityId,
            userId: userId,
            type: type,
            text: nil,
            timestamp: Date()
        )
        try await store.set(object: interaction, collection: collection, documentId: reactionId(userId: userId, activityId: activityId))
    }

    // Remove a user's reaction on an activity.
    func removeReaction(userId: String, activityId: String) async throws {
        try await store.delete(collection: collection, documentId: reactionId(userId: userId, activityId: activityId))
    }

    // Add a comment. Returns the new document ID.
    func addComment(text: String, userId: String, activityId: String) async throws -> String {
        let interaction = Interaction(
            activityId: activityId,
            userId: userId,
            type: .comment,
            text: text,
            timestamp: Date()
        )
        return try await store.create(object: interaction, collection: collection)
    }

    // Delete an interaction by its document ID.
    func deleteInteraction(interactionId: String) async throws {
        try await store.delete(collection: collection, documentId: interactionId)
    }

    // Fetch a user's reaction on an activity, or nil if none.
    func fetchUserReaction(userId: String, activityId: String) async -> Interaction? {
        return try? await store.fetch(type: Interaction.self, collection: collection, documentId: reactionId(userId: userId, activityId: activityId))
    }

    // Fetch every interaction on an activity. Sorted/filtered client-side
    // by callers to avoid requiring Firestore composite indexes.
    func fetchInteractions(for activityId: String) async throws -> [Interaction] {
        try await store.fetchAll(type: Interaction.self, collection: collection, filter: { ref in
            ref.whereField("activity_id", isEqualTo: activityId)
        })
    }

    // Fetch all likes and dislikes on an activity, most recent first.
    func fetchReactions(for activityId: String) async throws -> [Interaction] {
        let all = try await fetchInteractions(for: activityId)
        return all
            .filter { $0.type == .like || $0.type == .dislike }
            .sorted { $0.timestamp > $1.timestamp }
    }

    // Fetch all comments on an activity, oldest first.
    func fetchComments(for activityId: String) async throws -> [Interaction] {
        let all = try await fetchInteractions(for: activityId)
        return all
            .filter { $0.type == .comment }
            .sorted { $0.timestamp < $1.timestamp }
    }
    
    // Fetch all of a user's liked activities, oldest first.
    func fetchLikedActivityIds(for userId: String) async throws -> [String] {
        let interactions = try await store.fetchAll(type: Interaction.self, collection: collection, filter: { ref in
            ref.whereField("user_id", isEqualTo: userId)
                .whereField("type", isEqualTo: InteractionType.like.rawValue)
        })
        return interactions.map { $0.activityId }
    }
}
