//
//  ExpandReviewVC.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 4/14/26.
//

import UIKit

class ExpandReviewVC: UIViewController, UITextViewDelegate {

    var activity: Activity?
    var username: String?
    var avatarURL: String?
    
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
            // TODO open text field
        }
        
        activityView.onLikeTapped = {
            print("LIKE TAPPED INSIDE EXPAND REVIEW")
            // TODO add like to firebase? or do this inside ActivityCell
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

//    // Called when the user clicks on the view outside of the UITextField
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }
    
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
        guard let activity = activity else {
            return
        }
        
        activityView.configure(with: activity, username: username, avatarURL: avatarURL)
        
        let card = activityView.cardView
        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)
        
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
}
