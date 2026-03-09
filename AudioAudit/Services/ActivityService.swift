//
//  ActivityService.swift
//  AudioAudit
//
//  Created by Bersam Basagaoglu on 3/9/26.
//

import Foundation
import FirebaseFirestore

class ActivityService {

    static let shared = ActivityService()
    private let store = FirestoreService.shared
    private let collection = "activities"

    private init() {}


    // Log a listen activity. Returns the new document ID.
    func logListen(userId: String, song: String, artist: String) async throws -> String {
        let activity = Activity(
            userId: userId,
            type: .listen,
            song: song,
            artist: artist,
            rating: nil,
            timestamp: Date()
        )
        return try await store.create(object: activity, collection: collection)
    }

    // Log a review activity with a rating. Returns the new document ID.
    func logReview(userId: String, song: String, artist: String, rating: Int) async throws -> String {
        let activity = Activity(
            userId: userId,
            type: .review,
            song: song,
            artist: artist,
            rating: rating,
            timestamp: Date()
        )
        return try await store.create(object: activity, collection: collection)
    }


    // Fetch all activities for a user, ordered by most recent first.
    func fetchActivities(for userId: String) async throws -> [Activity] {
        try await store.fetchAll(type: Activity.self, collection: collection, filter: { ref in
            ref.whereField("user_id", isEqualTo: userId)
               .order(by: "timestamp", descending: true)
        })
    }

    // Fetch only reviews for a user.
    func fetchReviews(for userId: String) async throws -> [Activity] {
        try await store.fetchAll(type: Activity.self, collection: collection, filter: { ref in
            ref.whereField("user_id", isEqualTo: userId)
               .whereField("type", isEqualTo: ActivityType.review.rawValue)
               .order(by: "timestamp", descending: true)
        })
    }

    // Fetch only listens for a user.
    func fetchListens(for userId: String) async throws -> [Activity] {
        try await store.fetchAll(type: Activity.self, collection: collection, filter: { ref in
            ref.whereField("user_id", isEqualTo: userId)
               .whereField("type", isEqualTo: ActivityType.listen.rawValue)
               .order(by: "timestamp", descending: true)
        })
    }


    // Delete an activity by its document ID.
    func deleteActivity(activityId: String) async throws {
        try await store.delete(collection: collection, documentId: activityId)
    }
}
