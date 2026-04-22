//
//  ExpandReviewVC.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 4/14/26.
//

import UIKit

class ExpandReviewVC: UIViewController{

    var activity: Activity?
    var username: String?
    var avatarURL: String?
    
    let activityView = ActivityCellTableViewCell(style: .default, reuseIdentifier: nil)
    
    var commentCard: NewCommentView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            do {
                let reviewUser = try await UserService.shared.fetchUser(uid: activity!.userId)
                await MainActor.run {
                    username = reviewUser.name
                    avatarURL = reviewUser.profilePicURL
                    commentCard = NewCommentView(user: reviewUser)
                    setupActivity()
                    setupCommentField()
                    // TODO load comments from firebase backend
                }
            } catch {
                print("Failed to fetch user: \(error)")
                await MainActor.run {
                    setupActivity()
                }
            }
        }
        view.backgroundColor = .systemBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityView.onCommentTapped = {
            print("COMMENT TAPPED INSIDE EXPAND REVIEW")
            // TODO open text field
        }
        
        activityView.onCommentTapped = {
            print("LIKE TAPPED INSIDE EXPAND REVIEW")
        }
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        activityView.onCommentTapped = {
            print("COMMENT TAPPED")
        }
        activityView.onLikeTapped = {
            print("LIKE TAPPED")
        }
    }
    
    func setupCommentField() {
        guard let activity = activity else {
            return
        }
        let card = activityView.cardView
        NSLayoutConstraint.activate([
            commentCard!.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 8),
            commentCard!.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            commentCard!.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            commentCard!.heightAnchor.constraint(greaterThanOrEqualToConstant: 30)
        ])
    }
    
    private func setupActivity() {
        guard let activity = activity else {
            return
        }
        
        activityView.configure(with: activity, username: username, avatarURL: avatarURL)
        
        let card = activityView.cardView
        card.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(card)
        
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
}
