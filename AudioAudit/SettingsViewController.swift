//
//  SettingsViewController.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 3/2/26.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
    // tells the user what font size they've chosen
    @IBOutlet weak var fontLabel: UILabel!
    // the button outlet for the light / dark mode
    @IBOutlet weak var modeImage: UIButton!
    // other labels that need their font adjusted
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var toggleLabel: UILabel!
    @IBOutlet weak var mapLabel: UILabel!
    @IBOutlet weak var selectLabel: UILabel!
    @IBOutlet weak var smallerLabel: UILabel!
    @IBOutlet weak var largerLabel: UILabel!
    @IBOutlet weak var logoutButtonText: UIButton!
    @IBOutlet weak var fontSlider: UISlider!
    @IBOutlet weak var musicStatusLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let size = UserDefaults.standard.integer(forKey: "fontSize")
        fontLabel.text = "Current Font Size: \(size)"
        updateFontSize(size: Int(size), labels: [
            fontLabel,
            settingsLabel,
            toggleLabel,
            mapLabel,
            selectLabel,
            smallerLabel,
            largerLabel,
            musicStatusLabel
        ], buttons: [logoutButtonText])
        let darkMode = UserDefaults.standard.bool(forKey: "darkMode")
        if darkMode {
            modeImage.setImage(UIImage(systemName: "moon.fill"), for: .normal)
            modeImage.backgroundColor = .black
        } else {
            modeImage.setImage(UIImage(systemName: "sun.max.fill"), for: .normal)
            modeImage.backgroundColor = .white
        }
        let oldSize = (size - 15) / 2
        fontSlider.value = Float(oldSize)
        let isConnected = UserDefaults.standard.bool(forKey: "appleMusicConnected")
        if isConnected {
            musicStatusLabel.text = "Apple Music is Connected!"
        } else {
            musicStatusLabel.text = "Apple Music is Not Connected. Please Connect in System Settings"
        }
        self.tabBarController?.tabBar.isHidden = true
    }
    

    @IBAction func modeButton(_ sender: UIButton) {
        let isDark = view.window?.overrideUserInterfaceStyle == .dark
        
        if isDark {
            view.window?.overrideUserInterfaceStyle = .light
            sender.setImage(UIImage(systemName: "sun.max.fill"), for: .normal)
            UserDefaults.standard.set(false, forKey: "darkMode")
            modeImage.tintColor = .audioRed
            modeImage.backgroundColor = .white
        } else {
            view.window?.overrideUserInterfaceStyle = .dark
            sender.setImage(UIImage(systemName: "moon.fill"), for: .normal)
            UserDefaults.standard.set(true, forKey: "darkMode")
            modeImage.tintColor = .audioRed
            modeImage.backgroundColor = .black
        }
    }
    @IBAction func mapButton(_ sender: UISwitch) {
        let value = sender.isOn
        UserDefaults.standard.set(value, forKey: "showMap")
    }
    @IBAction func fontSelector(_ sender: UISlider) {
        let roundedValue = round(sender.value)
        sender.value = roundedValue
        let actualSize = 15 + (roundedValue * 2)
        fontLabel.text = "Current Font Size: \(Int(actualSize))"
        updateFontSize(size: Int(actualSize), labels: [
            fontLabel,
            settingsLabel,
            toggleLabel,
            mapLabel,
            selectLabel,
            smallerLabel,
            largerLabel,
            musicStatusLabel
        ], buttons: [logoutButtonText])
        UserDefaults.standard.set(actualSize, forKey: "fontSize")
    }
    @IBAction func logoutButton(_ sender: Any) {
        let alert = UIAlertController(
                title: "Log Out",
                message: "Are you sure you want to log out?",
                preferredStyle: .alert
            )
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            UserService.shared.clearCurrentUser()
            try? Auth.auth().signOut()
            self.view.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        })
        alert.addAction(cancelAction)
        alert.addAction(logoutAction)
        present(alert, animated: true)
    }
    
    func updateFontSize(size: Int, labels: [UILabel], buttons: [UIButton]) {
        let fontSize = CGFloat(size)
        
        for label in labels {
            label.font = label.font.withSize(fontSize)
        }
        
        for button in buttons {
            button.titleLabel?.font = button.titleLabel?.font.withSize(fontSize)
        }
    }
}
