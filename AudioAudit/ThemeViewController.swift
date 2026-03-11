//
//  ThemeViewController.swift
//  AudioAudit
//
//  Created by Brett Sestak on 3/9/26.
//

import UIKit

class ThemeViewController: UIViewController {

    @IBOutlet weak var themeOutlet: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let darkMode = UserDefaults.standard.bool(forKey: "darkMode")
        let mode = darkMode ? "Dark" : "Light"
        if darkMode {
            themeOutlet.setImage(UIImage(systemName: "moon.fill"), for: .normal)
            themeOutlet.backgroundColor = .black
            textLabel.text = "Tap to Change into " + mode + " Mode"
        } else {
            themeOutlet.setImage(UIImage(systemName: "sun.max.fill"), for: .normal)
            themeOutlet.backgroundColor = .white
            textLabel.text = "Tap to Change into " + mode + " Mode"
        }
    }
    @IBAction func themePressed(_ sender: UIButton) {
        let isDark = view.window?.overrideUserInterfaceStyle == .dark
        
        if isDark {
            view.window?.overrideUserInterfaceStyle = .light
            sender.setImage(UIImage(systemName: "sun.max.fill"), for: .normal)
            UserDefaults.standard.set(false, forKey: "darkMode")
            themeOutlet.tintColor = .audioRed
            themeOutlet.backgroundColor = .white
            textLabel.text = "Tap to Change into Dark Mode"
        } else {
            view.window?.overrideUserInterfaceStyle = .dark
            sender.setImage(UIImage(systemName: "moon.fill"), for: .normal)
            UserDefaults.standard.set(true, forKey: "darkMode")
            themeOutlet.tintColor = .audioRed
            themeOutlet.backgroundColor = .black
            textLabel.text = "Tap to Change into Light Mode"
        }
    }
    
    
}
