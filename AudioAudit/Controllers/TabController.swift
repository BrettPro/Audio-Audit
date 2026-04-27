//
//  TabController.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 3/6/26.
//

import UIKit

class TabController: UITabBarController {

    @IBOutlet weak var tabBarView: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.unselectedItemTintColor = UIColor.lightGray
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray2
        tabBarView.standardAppearance = tabBarAppearance
        tabBarView.scrollEdgeAppearance = tabBarAppearance
        isModalInPresentation = true
    }

}
