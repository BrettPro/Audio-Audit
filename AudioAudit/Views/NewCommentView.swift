//
//  NewCommentView.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 4/22/26.
//

import UIKit

class NewCommentView: UIView, UITextFieldDelegate  {
    
    var user: AAUser
    let avatar = UIImageView()
    let commentField = UITextField()
    
    var card: ActivityCellTableViewCell?

    init(user: AAUser) {
        self.user = user
        super.init(frame: .zero)
        commentField.delegate = self
        setupLayout()
//        Task {
//            await getUserPic()
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        commentField.placeholder = "Write comment here"
        commentField.translatesAutoresizingMaskIntoConstraints = false
        
        commentField.backgroundColor = .secondarySystemBackground
        commentField.layer.cornerRadius = 14
        commentField.textColor = .secondaryLabel
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: commentField.frame.height))
        commentField.leftView = paddingView
        commentField.leftViewMode = .always
    
    }
    
//    // Called when 'return' key pressed
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//    
//    // Called when the user clicks on the view outside of the UITextField
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }
}
