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

    let commentsStackView = UIStackView()
    private var commenterUsernames: [String: String] = [:]
    private var commenterAvatars: [String: String] = [:]
    
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
                }
                await loadComments()
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
        // Comment-tap focuses the composer; like is fully handled inside ActivityCell.
        activityView.onCommentTapped = { [weak self] in
            self?.commentCard?.commentField.becomeFirstResponder()
        }

        activityView.onAvatarTapped = {
            guard let user = self.user else {
                print("USER NOT LOADED, IGNORE TAP")
                return
            }
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

        commentCard?.postTapped = { [weak self] in
            self?.postComment()
        }
    }

    private func postComment() {
        guard let card = commentCard,
              let activityId = activity?.id,
              let userId = UserService.shared.currentUserId else { return }
        let text = card.commentField.text ?? ""
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != "Write comment here" else { return }

        card.commentField.text = nil
        card.commentField.resignFirstResponder()

        Task {
            do {
                _ = try await InteractionService.shared.addComment(text: trimmed, userId: userId, activityId: activityId)
                await activityView.refreshInteractionCounts()
                await loadComments()
            } catch {
                print("Failed to post comment: \(error)")
            }
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
            activityView.contentView.bottomAnchor.constraint(equalTo: activityView.bottomAnchor),

            activityView.topAnchor.constraint(equalTo: contentView.topAnchor),
            activityView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            activityView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])

        var bottomOfHeader: NSLayoutYAxisAnchor = activityView.bottomAnchor

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
                deleteButton.topAnchor.constraint(equalTo: activityView.bottomAnchor, constant: -8),
                deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            ])
            bottomOfHeader = deleteButton.bottomAnchor
        }

        commentsStackView.translatesAutoresizingMaskIntoConstraints = false
        commentsStackView.axis = .vertical
        commentsStackView.spacing = 12
        commentsStackView.alignment = .fill
        contentView.addSubview(commentsStackView)

        NSLayoutConstraint.activate([
            commentsStackView.topAnchor.constraint(equalTo: bottomOfHeader, constant: 8),
            commentsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            commentsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            commentsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
    }

    // Fetch comments for the current activity, load each commenter's user info, and rebuild the stack.
    func loadComments() async {
        guard let activityId = activity?.id else { return }
        do {
            let comments = try await InteractionService.shared.fetchComments(for: activityId)

            let unknownIds = Set(comments.map { $0.userId }).filter { commenterUsernames[$0] == nil }
            for uid in unknownIds {
                if let user = try? await UserService.shared.fetchUser(uid: uid) {
                    commenterUsernames[uid] = user.name
                    commenterAvatars[uid] = user.profilePicURL
                }
            }

            await MainActor.run {
                self.commentsStackView.arrangedSubviews.forEach {
                    self.commentsStackView.removeArrangedSubview($0)
                    $0.removeFromSuperview()
                }
                for comment in comments {
                    let view = CommentView(
                        comment: comment,
                        username: self.commenterUsernames[comment.userId],
                        avatarURL: self.commenterAvatars[comment.userId]
                    )
                    self.commentsStackView.addArrangedSubview(view)
                }
            }
        } catch {
            print("Failed to load comments: \(error)")
        }
    }
    
    func deletePost() {
        // TODO: implement delete logic
    }
}
