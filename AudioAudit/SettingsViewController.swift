//
//  SettingsViewController.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 3/2/26.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var fontLabel: UILabel!
    
    @IBOutlet weak var modeImage: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fontLabel.text = "Current Font Size: 3"
        modeImage.tintColor = .label
    }
    

    @IBAction func modeButton(_ sender: UIButton) {
        if overrideUserInterfaceStyle == .dark {
            overrideUserInterfaceStyle = .light
            sender.setImage(UIImage(systemName: "sun.max.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
            modeImage.tintColor = .white
        } else {
            overrideUserInterfaceStyle = .dark
            sender.setImage(UIImage(systemName: "moon.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
            modeImage.tintColor = .black
        }
    }
    @IBAction func mapButton(_ sender: Any) {
    }
    @IBAction func fontSelector(_ sender: UISlider) {
        let roundedValue = round(sender.value)
        sender.value = roundedValue
        fontLabel.text = "Current Font Size: \(Int(roundedValue))"
        
        
    }
    @IBAction func logoutButton(_ sender: Any) {
        let alert = UIAlertController(
                title: "Log Out",
                message: "Are you sure you want to log out?",
                preferredStyle: .alert
            )
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive)
        alert.addAction(cancelAction)
        alert.addAction(logoutAction)
        present(alert, animated: true)
    }
}
