//
//  MapService.swift
//  AudioAudit
//
//  Created by Bersam Basagaoglu on 3/9/26.
//

import Foundation
import FirebaseFirestore

class MapService {

    static let shared = MapService()
    private let store = FirestoreService.shared
    private let collection = "map"

    private init() {}


    // Drop a pin for a song at a location. Returns the new document ID.
    func dropPin(userId: String, song: String, artist: String, latitude: Double, longitude: Double) async throws -> String {
        let pin = MapPin(
            userId: userId,
            song: song,
            artist: artist,
            latitude: latitude,
            longitude: longitude,
            timestamp: Date()
        )
        return try await store.create(object: pin, collection: collection)
    }


    // Fetch all pins for a user.
    func fetchPins(for userId: String) async throws -> [MapPin] {
        try await store.fetchAll(type: MapPin.self, collection: collection, filter: { ref in
            ref.whereField("user_id", isEqualTo: userId)
               .order(by: "timestamp", descending: true)
        })
    }

    // Fetch all pins (e.g. for a global map view).
    func fetchAllPins() async throws -> [MapPin] {
        try await store.fetchAll(type: MapPin.self, collection: collection)
    }


    func deletePin(pinId: String) async throws {
        try await store.delete(collection: collection, documentId: pinId)
    }
}
