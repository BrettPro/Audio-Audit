//
//  RegisterViewController.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 3/4/26.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var retypeField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameField.delegate = self
        passwordField.delegate = self
        logoView.transform = CGAffineTransform(rotationAngle: rotAngle)
        registerButton.tintColor = UIColor.audioRed
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
    
    func isValidCred(_ cred: String) -> Bool {
       let credRegEx =
           "[A-Z0-9a-z._]{2,64}"
       let credPred = NSPredicate(format:"SELF MATCHES %@",
           credRegEx)
       return credPred.evaluate(with: cred)
    }
      
    @IBAction func registerPressed(_ sender: Any) {
        var validCreds: Bool = isValidCred(usernameField.text!) && isValidCred(passwordField.text!)
        var passMatch: Bool = passwordField.text == retypeField.text
        var uniqueCreds: Bool = false
        // TODO ensure username is unique in firebase
        if !validCreds {
            let alertControl = UIAlertController(title: "Invalid registration", message: "Username or password must contain at least two English characters, numbers, or symbols.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertControl.addAction(okAction)
            self.present(alertControl, animated: true)
        } else if !passMatch {
            let alertControl = UIAlertController(title: "Invalid registration", message: "Passwords must match.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertControl.addAction(okAction)
            self.present(alertControl, animated: true)
        } else if !uniqueCreds {
            let alertControl = UIAlertController(title: "Invalid registration", message: "Username already taken.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertControl.addAction(okAction)
            self.present(alertControl, animated: true)
        }
        // TODO else store username and password in firebase, then segue to activity feed
    }
    
}
