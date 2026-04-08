//
//  SpotifyViewController.swift
//  AudioAudit
//
//  Created by Brett Sestak on 3/9/26.
//

import UIKit
import UserNotifications

class SpotifyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    @IBAction func linkButtonPressed(_ sender: Any) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            
            DispatchQueue.main.async {
                if granted {
                    UserDefaults.standard.set(true, forKey: "notificationsEnabled")
                    
                    let alert = UIAlertController(
                        title: "Notifications Enabled",
                        message: "You will now receive notifications.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    
                } else {
                    UserDefaults.standard.set(false, forKey: "notificationsEnabled")
                    
                    let alert = UIAlertController(
                        title: "Notifications Disabled",
                        message: "Please enable notifications in Settings.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
