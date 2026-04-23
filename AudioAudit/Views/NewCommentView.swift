//
//  NewCommentView.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 4/22/26.
//

import UIKit

class NewCommentView: UIView {
    
    var user: AAUser
    let avatar = UIImageView()
    let commentField = UITextView()
    let postButton = UIButton(type: .system)
    var postTapped: (() -> Void)?
    
    var card: ActivityCellTableViewCell?

    init(user: AAUser) {
        self.user = user
        super.init(frame: .zero)
        setupLayout()
//        Task {
//            await getUserPic()
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        var fontSize = 0
        if UserDefaults.standard.object(forKey: "fontSize") != nil {
            fontSize = UserDefaults.standard.integer(forKey: "fontSize")
        } else {
            fontSize = 15
        }
        self.backgroundColor = .secondarySystemBackground
        self.layer.cornerRadius = 14
        
        commentField.text = "Write comment here"
        commentField.translatesAutoresizingMaskIntoConstraints = false
        commentField.textColor = .secondaryLabel
        commentField.isScrollEnabled = false
        commentField.layer.cornerRadius = 14
        commentField.font = UIFont.systemFont(ofSize: CGFloat(fontSize - 1))
        commentField.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 56)

        addSubview(commentField)
    
        NSLayoutConstraint.activate([
            commentField.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            commentField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            commentField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            commentField.heightAnchor.constraint(greaterThanOrEqualToConstant: CGFloat(fontSize)),
            commentField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)
        ])
        
        //postButton.setTitle("Post", for: .normal)
        postButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        postButton.tintColor = .white
        postButton.translatesAutoresizingMaskIntoConstraints = false
        postButton.backgroundColor = .audioRed
        postButton.setTitleColor(.white, for: .normal)
        postButton.layer.cornerRadius = 14
        let action = UIAction() {_ in
            self.postTapped!()
        }
        postButton.addAction(action, for: .touchUpInside)
        addSubview(postButton)

        NSLayoutConstraint.activate([
            postButton.trailingAnchor.constraint(equalTo: commentField.trailingAnchor, constant: -8),
            postButton.centerYAnchor.constraint(equalTo: commentField.centerYAnchor),
            postButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 50),
            postButton.heightAnchor.constraint(greaterThanOrEqualToConstant: CGFloat(36)),
        ])
        //TODO add avatar
    }

}
