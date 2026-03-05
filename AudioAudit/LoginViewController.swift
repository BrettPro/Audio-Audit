//
//  LoginViewController.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 3/2/26.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.delegate = self
        passwordField.delegate = self
        logoView.transform = CGAffineTransform(rotationAngle: rotAngle)
        loginButton.tintColor = UIColor.audioRed
        accountButton.tintColor = UIColor.audioRed
    }
    

    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        var userAuth: Bool = false
        // TODO authenticate in firebase
        if !userAuth {
            let alertControl = UIAlertController(title: "Invalid login", message: "Username or password not recognized.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertControl.addAction(okAction)
            self.present(alertControl, animated: true)
        }
        // TODO else segue to activity feed
    }
}
