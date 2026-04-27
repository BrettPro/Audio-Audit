//
//  Quiz.swift
//  AudioAudit
//
//  Created by Bersam Basagaoglu on 3/9/26.
//

import Foundation
import FirebaseFirestore

struct Quiz: Codable, Identifiable {
    @DocumentID var id: String?
    var quizId: String
    var userId: String
    var correctAnswers: [String]
    var score: Int
    var total: Int
    var timestamp: Date

    enum CodingKeys: String, CodingKey {
        case id
        case quizId = "quiz_id"
        case userId = "user_id"
        case correctAnswers = "correct_answers"
        case score
        case total
        case timestamp
    }
}
