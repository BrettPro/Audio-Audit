//
//  SpotifyViewController.swift
//  AudioAudit
//
//  Created by Brett Sestak on 3/9/26.
//

import UIKit
import MusicKit

class SpotifyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func linkSpotifyPressed(_ sender: Any) {
        Task {
            let status = await MusicAuthorization.request()

            if status == .authorized {
                let alert = UIAlertController(
                        title: "Account Successfully Linked!",
                        message: "",
                        preferredStyle: .alert
                    )
                let action = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(action)
                present(alert, animated: true)
                UserDefaults.standard.set(true, forKey: "appleMusicConnected")
            } else {
                let alert = UIAlertController(
                        title: "Error in Linking Account",
                        message: "Please allow Apple Music access in settings",
                        preferredStyle: .alert
                    )
                let action = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(action)
                present(alert, animated: true)
            }
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
