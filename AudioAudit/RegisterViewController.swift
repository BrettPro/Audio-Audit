//
//  RegisterViewController.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 3/4/26.
//

import UIKit
import FirebaseAuth

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
    
    func isValidEmail(_ email: String) -> Bool {
       let emailRegEx =
           "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
       let emailPred = NSPredicate(format:"SELF MATCHES %@",
           emailRegEx)
       return emailPred.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
       let minPasswordLength = 2
       return password.count >= minPasswordLength
    }
      
    @IBAction func registerPressed(_ sender: Any) {
        let validCreds: Bool = isValidEmail(usernameField.text!) && isValidPassword(passwordField.text!)
        let passMatch: Bool = passwordField.text == retypeField.text
        if !validCreds {
            let alertControl = UIAlertController(title: "Invalid registration", message: "Email or password must contain at least two English characters, numbers, or symbols.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertControl.addAction(okAction)
            self.present(alertControl, animated: true)
        } else if !passMatch {
            let alertControl = UIAlertController(title: "Invalid registration", message: "Passwords must match.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertControl.addAction(okAction)
            self.present(alertControl, animated: true)
            // TODO check if firebase already accounts for unique usernames
//        } else if !uniqueCreds {
//            let alertControl = UIAlertController(title: "Invalid registration", message: "Username already taken.", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "OK", style: .default)
//            alertControl.addAction(okAction)
//            self.present(alertControl, animated: true)
        } else {
            Auth.auth().createUser(withEmail: usernameField.text!, password: passwordField.text!) {
                authResult, error in
                if let error = error as NSError? {
                    let alertControl = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default)
                    alertControl.addAction(okAction)
                    self.present(alertControl, animated: true)
                    return
                }

                // Create user doc in Firestore -- Bersam Testing
                if let uid = authResult?.user.uid {
                    Task {
                        do {
                            try await UserService.shared.createUser(
                                uid: uid,
                                name: self.usernameField.text!,
                                email: self.usernameField.text!
                            )
                        } catch {
                            print("Failed to create user doc: \(error)")
                        }
                    }
                }

                self.performSegue(withIdentifier: "RegistertoOnboard", sender: nil)
            }
        }
    }
    
}
