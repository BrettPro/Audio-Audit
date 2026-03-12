//
//  LoginViewController.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 3/2/26.
//

import UIKit
import FirebaseAuth

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
        guard let email = usernameField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            print("ERROR: BAD LOGIN")
            let alertControl = UIAlertController(title: "Invalid login", message: "Please enter your email and password.", preferredStyle: .alert)
            alertControl.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertControl, animated: true)
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("SIGN IN ERROR")
                let alertControl = UIAlertController(title: "Invalid login", message: error.localizedDescription, preferredStyle: .alert)
                alertControl.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alertControl, animated: true)
            } else {
                print("RESULT: \(authResult, default: "idek")")
                Task {
                    do {
                        try await UserService.shared.loadCurrentUser()
                    } catch {
                        print("LOGIN ERROR: Failed to load current user: \(error)")
                    }
                    self.performSegue(withIdentifier: "LoginToHome", sender: nil)
                }
            }
        }
    }
}
