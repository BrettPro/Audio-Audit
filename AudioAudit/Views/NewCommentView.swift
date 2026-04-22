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
        self.backgroundColor = .secondarySystemBackground
        self.layer.cornerRadius = 14
        
        commentField.text = "Write comment here"
        commentField.translatesAutoresizingMaskIntoConstraints = false
        commentField.textColor = .secondaryLabel
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: commentField.frame.height))
        commentField.leftView = paddingView
        commentField.leftViewMode = .always
        addSubview(commentField)
    
        NSLayoutConstraint.activate([
            commentField.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            commentField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            commentField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
        ])
        //TODO add avatar and send button
    }
    

}
