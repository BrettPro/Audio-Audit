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
        
        // TODO figure out why none of these change unselected item to gray
        self.tabBar.unselectedItemTintColor = UIColor.lightGray
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray2
        // tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.lightGray]
        // tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.lightGray
        tabBarView.standardAppearance = tabBarAppearance
        tabBarView.scrollEdgeAppearance = tabBarAppearance
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
