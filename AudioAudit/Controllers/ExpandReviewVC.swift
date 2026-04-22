//
//  ExpandReviewVC.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 4/14/26.
//

import UIKit

class ExpandReviewVC: UIViewController, UITextFieldDelegate {

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
                    commentCard?.commentField.delegate = self
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
        
        activityView.onLikeTapped = {
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
    
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commentCard?.commentField.resignFirstResponder()
        return true
    }

    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setupCommentField() {
        guard let activity = activity else {
            return
        }
        view.addSubview(commentCard!)
        commentCard?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            commentCard!.topAnchor.constraint(equalTo: activityView.cardView.bottomAnchor, constant: 8),
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
