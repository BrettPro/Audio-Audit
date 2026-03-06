//
//  LoadingViewController.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 3/4/26.
//

import UIKit

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
            self.performSegue(withIdentifier: "LoginSegue", sender: nil)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
