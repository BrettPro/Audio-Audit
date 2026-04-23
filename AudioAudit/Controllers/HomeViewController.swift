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
    var usernames: [String: String] = [:]
    var avatarURLs: [String: String] = [:]
    private var emptyStateLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        activityTableView.separatorStyle = .none

        activityTableView.dataSource = self
        activityTableView.delegate = self

        activityTableView.rowHeight = UITableView.automaticDimension
        activityTableView.estimatedRowHeight = 200
        activityTableView.separatorStyle = .none
        activityTableView.backgroundColor = .systemBackground
        activityTableView.isScrollEnabled = true
        activityTableView.alwaysBounceVertical = true

        setupAddButton()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        activityTableView.refreshControl = refreshControl
        
        loadFriendsFeed()
    }

    @objc func handleRefresh() {
        loadFriendsFeed()
    }
    
    func setupAddButton() {
        let addButton = UIButton(type: .system)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)), for: .normal)
        addButton.tintColor = .white
        addButton.backgroundColor = .audioRed
        addButton.layer.cornerRadius = 28
        addButton.addTarget(self, action: #selector(addActivityTapped), for: .touchUpInside)
        
        // button shadow
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOpacity = 0.3
        addButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        addButton.layer.shadowRadius = 8
        
        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            addButton.widthAnchor.constraint(equalToConstant: 56),
            addButton.heightAnchor.constraint(equalToConstant: 56),
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }

    @objc func addActivityTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addVC = storyboard.instantiateViewController(withIdentifier: "AddActivityVC")
        let nav = UINavigationController(rootViewController: addVC)
        present(nav, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func loadFriendsFeed() {
        guard let currentUser = UserService.shared.currentUser else {
            print("HOME ERROR: No current user found")
            activities = []
            activityTableView.reloadData()
            return
        }

        var friendIds = currentUser.friends
        if let myId = UserService.shared.currentUserId {
            friendIds.append(myId)
        }

        Task {
            do {
                let fetchedActivities = try await ActivityService.shared.fetchFriendsFeed(friendIds: friendIds)

                // Fetch usernames for each unique userId
                let uniqueUserIds = Set(fetchedActivities.map { $0.userId })
                var names: [String: String] = [:]
                var avatars: [String: String] = [:]
                for uid in uniqueUserIds {
                    if let user = try? await UserService.shared.fetchUser(uid: uid) {
                        names[uid] = user.name
                        avatars[uid] = user.profilePicURL
                    }
                }

                await MainActor.run {
                    self.activities = fetchedActivities
                    self.usernames = names
                    self.avatarURLs = avatars
                    self.activityTableView.reloadData()
                    
                    self.activityTableView.refreshControl?.endRefreshing()
                    
                    self.updateEmptyState(friendCount: friendIds.count)
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
    
    private func updateEmptyState(friendCount: Int) {
        if activities.isEmpty {
            if emptyStateLabel == nil {
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.numberOfLines = 0
                label.textAlignment = .center
                label.textColor = .secondaryLabel
                label.font = .systemFont(ofSize: 16)
                label.text = friendCount <= 1
                    ? "Add friends to see their activity"
                    : "No activity yet"
                view.addSubview(label)
                NSLayoutConstraint.activate([
                    label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
                    label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
                ])
                emptyStateLabel = label
            }
            emptyStateLabel?.isHidden = false
        } else {
            emptyStateLabel?.isHidden = true
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

        cell.configure(with: activity, username: usernames[activity.userId], avatarURL: avatarURLs[activity.userId])

        return cell
    }
    
    // sends selected activity to expandVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ExpandSegue" {
            if let indexPath = activityTableView.indexPathForSelectedRow {
                let selectedItem = activities[indexPath.row]
                let destinationVC = segue.destination as! ExpandReviewVC
                destinationVC.activity = selectedItem
            }
        }
    }
}
