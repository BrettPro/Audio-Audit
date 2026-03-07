//
//  HomeViewController.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 3/2/26.
//

import UIKit

struct Activity {
    let username: String
    let albumTitle: String
    let songName: String
    let artistName: String
    let reviewText: String?
    let profileImageName: String
    let albumCoverImageName: String
}

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var activityTableView: UITableView!
    var activities: [Activity] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        activityTableView.separatorStyle = .none
        
        activityTableView.dataSource = self
        activityTableView.delegate = self

        activityTableView.rowHeight = UITableView.automaticDimension
        activityTableView.estimatedRowHeight = 110
        activityTableView.separatorStyle = .none
        activityTableView.backgroundColor = .white
        //view.backgroundColor = .systemBackground

        loadSampleActivities()
        // Do any additional setup after loading the view.
    }
    
    func loadSampleActivities() {
        
        let activity1 = Activity(
            username: "Emma",
            albumTitle: "Blonde",
            songName: "Ivy",
            artistName: "Frank Ocean",
            reviewText: "Beautiful production and vocals. This is one of those songs that gets better every time.",
            profileImageName: "load_logo_final",
            albumCoverImageName: "load_logo_final"
        )
        
        let activity2 = Activity(
            username: "Leo",
            albumTitle: "Currents",
            songName: "The Less I Know the Better",
            artistName: "Tame Impala",
            reviewText: "Still one of my favorite songs ever.",
            profileImageName: "load_logo_final",
            albumCoverImageName: "load_logo_final"
        )
        
        
        activities = [activity1, activity2]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let activity = activities[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ActivityCell",
            for: indexPath
        ) as! ActivityCellTableViewCell

        cell.configure(with: activity)

        return cell
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
