//
//  FirestoreService.swift
//  AudioAudit
//
//  Created by Bersam Basagaoglu on 3/9/26.
//
// ---------------------
// Design Decisions:
//
// Model Designg:
// Models use Codable so Swift auto converts them to/from Firestore docs.
// Models use Identifiable so each one has a unique id.
//
// Service Design:
// FirestoreService is a singleton (shared) that handles generic CRUD for models
// Each collection has its own service (ActivityService, FriendService, QuizService, UserService)

import Foundation
import FirebaseFirestore

class FirestoreService {

    static let shared = FirestoreService()
    let db = Firestore.firestore()

    private init() {}

    // Create a new document, creates new id, returns that id
    func create<T: Encodable>(object: T, collection: String) async throws -> String {
        let ref = try db.collection(collection).addDocument(from: object)
        return ref.documentID
    }

    // Sets a document given an id
    func set<T: Encodable>(object: T, collection: String, documentId: String) async throws {
        try db.collection(collection).document(documentId).setData(from: object)
    }

    // Get document based on id
    func fetch<T: Decodable>(type: T.Type, collection: String, documentId: String) async throws -> T {
        let snapshot = try await db.collection(collection).document(documentId).getDocument()
        return try snapshot.data(as: T.self)
    }

    // Gets all documents based on a query
    func fetchAll<T: Decodable>(type: T.Type, collection: String, filter: ((CollectionReference) -> Query)? = nil) async throws -> [T] {
        let ref = db.collection(collection)
        let snapshot: QuerySnapshot

        if filter != nil {
            snapshot = try await filter!(ref).getDocuments()
        } else {
            snapshot = try await ref.getDocuments()
        }

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: T.self)
        }
    }

    // Update specific fields on a document given an id
    func update(collection: String, documentId: String, fields: [String: Any]) async throws {
        try await db.collection(collection).document(documentId).updateData(fields)
    }

    // Deletes a document given by id
    func delete(collection: String, documentId: String) async throws {
        try await db.collection(collection).document(documentId).delete()
    }
}
