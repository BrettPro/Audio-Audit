//
//  LoadingViewController.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 3/4/26.
//

import UIKit
import FirebaseAuth

// angle to rotate logo. 6 degrees
let rotAngle = CGFloat.pi / 30.0

class LoadingViewController: UIViewController {

    @IBOutlet weak var loadLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationController?.isNavigationBarHidden = true
        
        // rotate logo for a spotify look
        loadLogo.transform = CGAffineTransform(rotationAngle: rotAngle)
        
        // timer makes splash screen last for 3 sec
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            if self.isUserLoggedIn() {
                self.performSegue(withIdentifier: "HomeSegue", sender: nil)
            } else {
                self.performSegue(withIdentifier: "LoginSegue", sender: nil)
            }
            
        }
    }
    
    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }

}
