//
//  ProfileViewController.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 3/2/26.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var profileTableView: UITableView!
    var selectedTab = 0
    var testImage: UIImageView!
    var activities: [Activity] = []
    var tabBar = TabBarView()

    override func viewDidLoad() {
        super.viewDidLoad()
        testImage = UIImageView(image: UIImage(named: "loadLogoFinal"))
        profileTableView.dataSource = self
        profileTableView.delegate = self
        profileTableView.register(ActivityCellTableViewCell.self, forCellReuseIdentifier: "ActivityCell")
        guard let currentUser = UserService.shared.currentUser else {
            print("PROFILE ERROR: No current user found")
            activities = []
            profileTableView.reloadData()
            return
        }
        let header = ProfileHeaderView(user: currentUser)
        header.frame = CGRect(x: 0, y: 0, width: profileTableView.bounds.width, height: 150)
        profileTableView.tableHeaderView = header
        tabBar.onTabSelected = { tab in
            self.selectedTab = tab
            self.profileTableView.reloadData()
        }
        Task {
            do {
                let fetchedActivities = try await ActivityService.shared.fetchActivities(for: UserService.shared.currentUserId!)
                await MainActor.run {
                    self.activities = fetchedActivities
                    self.profileTableView.reloadData()
                }
            } catch {
                print("Error loading user journal: \(error.localizedDescription)")

                await MainActor.run {
                    self.activities = []
                    self.profileTableView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //addSampleReview()
        self.tabBarController?.tabBar.isHidden = false
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tabBar
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO pull from firebase. can probably just
        // reuse code from Leo's work?
        let activity = activities[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ActivityCell",
            for: indexPath
        ) as! ActivityCellTableViewCell

        cell.configure(with: activity, username: UserService.shared.currentUser?.name)
        return cell
    }

    func addSampleReview() {
        guard let uid = UserService.shared.currentUserId else { return }
        Task {
            do {
                _ = try await ActivityService.shared.logReview(
                    userId: uid,
                    song: "Sample Song",
                    artist: "Sample Artist",
                    rating: 5
                )
                print("Sample review added")
            } catch {
                print("Failed to add sample review: \(error)")
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
