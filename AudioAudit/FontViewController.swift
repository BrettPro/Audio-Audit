//
//  FontViewController.swift
//  AudioAudit
//
//  Created by Brett Sestak on 3/9/26.
//

import UIKit

class FontViewController: UIViewController {
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var smallerLabel: UILabel!
    @IBOutlet weak var largerLabel: UILabel!
    
    var fontSize = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.object(forKey: "fontSize") != nil {
            fontSize = UserDefaults.standard.integer(forKey: "fontSize")
        }
        labelText.font = labelText.font.withSize(CGFloat(fontSize))
        smallerLabel.font = smallerLabel.font.withSize(CGFloat(fontSize))
        largerLabel.font = largerLabel.font.withSize(CGFloat(fontSize))
        
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
    

}
