//
//  HomeViewController.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 3/2/26.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var activityTableView: UITableView!
    var activities: [Activity] = []
    var currentUser: AAUser?
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

        //loadFriendsFeed()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            loadFriendsFeed()
    }
    
    func loadFriendsFeed() {
           guard let currentUser = currentUser else {
               print("No current user found")
               activities = []
               activityTableView.reloadData()
               return
           }

           let friendIds = currentUser.friends

           Task {
               do {
                   let fetchedActivities = try await ActivityService.shared.fetchFriendsFeed(friendIds: friendIds)

                   await MainActor.run {
                       self.activities = fetchedActivities
                       self.activityTableView.reloadData()
                   }
               } catch {
                   print("Error loading friends feed: \(error.localizedDescription)")

                   await MainActor.run {
                       self.activities = []
                       self.activityTableView.reloadData()
                   }
               }
           }
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
