//
//  Font_2_ViewController.swift
//  AudioAudit
//
//  Created by Brett Sestak on 4/7/26.
//

import UIKit

class Font_2_ViewController: UIViewController {

    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var smallerLabel: UILabel!
    @IBOutlet weak var largerLabel: UILabel!
    @IBOutlet weak var sliderOutlet: UISlider!
    
    var fontSize = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            
            // Load saved font size
            if let savedFontSize = UserDefaults.standard.object(forKey: "fontSize") as? Int {
                fontSize = savedFontSize
            } else {
                fontSize = 15 // default
            }

            // Update labels
            labelText.font = labelText.font.withSize(CGFloat(fontSize))
            smallerLabel.font = smallerLabel.font.withSize(CGFloat(fontSize))
            largerLabel.font = largerLabel.font.withSize(CGFloat(fontSize))
            
            // Update slider to match current font size
            // Reverse calculation from sliderMoved: fontSize = 15 + (slider.value * 2)
            sliderOutlet.value = Float(fontSize - 15) / 2
    }
    
    @IBAction func sliderMoved(_ sender: UISlider) {
        let roundedValue = round(sender.value)
        sender.value = roundedValue
        fontSize = Int(15 + (roundedValue * 2))
        UserDefaults.standard.set(fontSize, forKey: "fontSize")
        labelText.font = labelText.font.withSize(CGFloat(fontSize))
        smallerLabel.font = smallerLabel.font.withSize(CGFloat(fontSize))
        largerLabel.font = largerLabel.font.withSize(CGFloat(fontSize))
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
}
