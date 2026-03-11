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
        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        // Do any additional setup after loading the view.
    }
    
    @IBAction func linkButtonPressed(_ sender: Any) {
        Task { @MainActor in
            let status = await MusicAuthorization.request()
            
            if status != .authorized {
                UserDefaults.standard.set(false, forKey: "appleMusicConnected")
                
                let alert = UIAlertController(
                    title: "Access Denied",
                    message: "Please allow Apple Music access in Settings.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                present(alert, animated: true)
                return
            }
            
            // Authorized — now check subscription
            let hasSubscription: Bool
            
            do {
                let subscription = try await MusicSubscription.current
                hasSubscription = subscription.canPlayCatalogContent
            } catch {
                hasSubscription = false
            }
            
            if hasSubscription {
                UserDefaults.standard.set(true, forKey: "appleMusicConnected")
                
                let alert = UIAlertController(
                    title: "Account Successfully Linked!",
                    message: "Your Apple Music account is linked!",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                present(alert, animated: true)
                
            } else {
                UserDefaults.standard.set(false, forKey: "appleMusicConnected")
                
                let alert = UIAlertController(
                    title: "Apple Music Not Active",
                    message: "You need an active Apple Music subscription.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
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
