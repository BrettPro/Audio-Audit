//
//  QuizService.swift
//  AudioAudit
//
//  Created by Bersam Basagaoglu on 3/9/26.
//

import Foundation
import FirebaseFirestore

class QuizService {

    static let shared = QuizService()
    private let store = FirestoreService.shared
    private let collection = "quizzes"

    private init() {}

    // Save a quiz attempt. Returns the new document ID.
    func saveAttempt(quizId: String, userId: String, correctAnswers: [String], score: Int) async throws -> String {
        let quiz = Quiz(
            quizId: quizId,
            userId: userId,
            correctAnswers: correctAnswers,
            score: score
        )
        return try await store.create(object: quiz, collection: collection)
    }

    // Fetch all quiz attempts for a user.
    func fetchAttempts(for userId: String) async throws -> [Quiz] {
        try await store.fetchAll(type: Quiz.self, collection: collection, filter: { ref in
            ref.whereField("user_id", isEqualTo: userId)
        })
    }

    // Fetch all attempts for a specific quiz.
    func fetchAttempts(forQuiz quizId: String) async throws -> [Quiz] {
        try await store.fetchAll(type: Quiz.self, collection: collection, filter: { ref in
            ref.whereField("quiz_id", isEqualTo: quizId)
        })
    }

    // Fetch a user's best score for a specific quiz.
    func fetchBestScore(userId: String, quizId: String) async throws -> Quiz? {
        let results = try await store.fetchAll(type: Quiz.self, collection: collection, filter: { ref in
            ref.whereField("user_id", isEqualTo: userId)
               .whereField("quiz_id", isEqualTo: quizId)
               .order(by: "score", descending: true)
               .limit(to: 1)
        })
        return results.first
    }

    func deleteAttempt(attemptId: String) async throws {
        try await store.delete(collection: collection, documentId: attemptId)
    }
}
