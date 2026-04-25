//
//  ExpandReviewVC.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 4/14/26.
//

import UIKit

class ExpandReviewVC: UIViewController, UITextViewDelegate {

    var user: AAUser?
    var activity: Activity?
    var username: String?
    var avatarURL: String?
    var isCurrentUser = true
    
    let activityView = ActivityCellTableViewCell(style: .default, reuseIdentifier: nil)
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    var commentCard: NewCommentView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -100),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)
        
        Task {
            do {
                let reviewUser = try await UserService.shared.fetchUser(uid: activity!.userId)
                await MainActor.run {
                    isCurrentUser = reviewUser.id == UserService.shared.currentUserId
                    user = reviewUser
                    username = reviewUser.name
                    avatarURL = reviewUser.profilePicURL
                    commentCard = NewCommentView(user: reviewUser)
                    commentCard?.commentField.delegate = self
                    setupActivity()
                    setupCommentField()
                    // TODO: load comments from firebase backend
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (commentCard!.commentField.text == "Write comment here") {
            commentCard!.commentField.text = nil
        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            if let commentCard = self.commentCard {
//                self.scrollView.scrollRectToVisible(commentCard.frame, animated: true)
//            }
//        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (commentCard!.commentField.text.isEmpty) {
            textView.text = "Write comment here"
            textView.textColor = .secondaryLabel
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityView.onCommentTapped = {
            print("COMMENT TAPPED INSIDE EXPAND REVIEW")
        }
        
        activityView.onLikeTapped = {
            print("LIKE TAPPED INSIDE EXPAND REVIEW")
            // TODO: add like to firebase? or do this inside ActivityCell
        }
        
        activityView.onAvatarTapped = {
            guard let user = self.user else {
                print("USER NOT LOADED, IGNORE TAP")
                return
            }
            print("AVATAR TAPPED INSIDE EXPAND REVIEW")
            self.performSegue(withIdentifier: "ShowProfile", sender: user)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowProfile" {
            let profileVC = segue.destination as! ProfileViewController
            profileVC.isCurrentUser = false
            profileVC.displayUser = sender as? AAUser
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
    
    func setupCommentField() {
        guard activity != nil else {
            return
        }

        view.addSubview(commentCard!)
        commentCard?.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            commentCard!.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            commentCard!.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            commentCard!.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -8),
            commentCard!.heightAnchor.constraint(greaterThanOrEqualToConstant: 85),
        ])

        commentCard?.postTapped = {
            print("POST BUTTON TAPPED")
        }
    }
    
    private func setupActivity() {
        guard let activity = activity else { return }
        
        activityView.configure(with: activity, username: username, avatarURL: avatarURL)
        activityView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(activityView)
        
        activityView.contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            activityView.contentView.topAnchor.constraint(equalTo: activityView.topAnchor),
            activityView.contentView.leadingAnchor.constraint(equalTo: activityView.leadingAnchor),
            activityView.contentView.trailingAnchor.constraint(equalTo: activityView.trailingAnchor),
            activityView.contentView.bottomAnchor.constraint(equalTo: activityView.bottomAnchor)
        ])
        if isCurrentUser {
            let deleteButton = UIButton()
            deleteButton.translatesAutoresizingMaskIntoConstraints = false
            deleteButton.setTitle("Delete", for: .normal)
            deleteButton.setTitleColor(.audioRed, for: .normal)
            let action = UIAction() { _ in
                print("DELETE PRESSED")
                self.deletePost()
            }
            deleteButton.addAction(action, for: .touchUpInside)
            contentView.addSubview(deleteButton)
            
            NSLayoutConstraint.activate([
                activityView.topAnchor.constraint(equalTo: contentView.topAnchor),
                activityView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                activityView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                
                deleteButton.topAnchor.constraint(equalTo: activityView.bottomAnchor, constant: -8),
                deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
                deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
            ])
        } else {
            NSLayoutConstraint.activate([
                activityView.topAnchor.constraint(equalTo: contentView.topAnchor),
                activityView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                activityView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                activityView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }
    }
    
    func deletePost() {
        // TODO: implement delete logic
    }
}
