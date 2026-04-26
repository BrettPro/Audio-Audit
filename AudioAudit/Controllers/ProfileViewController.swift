//
//  ProfileViewController.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 3/2/26.
//

import UIKit
import FirebaseStorage

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var profileTableView: UITableView!
    var header: ProfileHeaderView?
    var selectedTab = 0
    var testImage: UIImageView!
    var activities: [Activity] = []
    // TODO: when liked tab selected, display liked activities
    var likedActivities: [Activity] = []
    var tabBar = TabBarView()
    
    var isCurrentUser = true
    var displayUser: AAUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        let friendsButton = UIBarButtonItem(
            image: UIImage(systemName: "person.2.fill"),
            style: .plain,
            target: self,
            action: #selector(friendsTapped)
        )
        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .plain,
            target: self,
            action: #selector(settingsTapped)
        )
        navigationItem.rightBarButtonItems = [settingsButton, friendsButton]
        
        // hides settings and friends buttons if on non-current user profile
        if !isCurrentUser {
            friendsButton.isHidden = true
            settingsButton.isHidden = true
        } else {
            friendsButton.isHidden = false
            settingsButton.isHidden = false
        }
        testImage = UIImageView(image: UIImage(named: "loadLogoFinal"))
        profileTableView.dataSource = self
        profileTableView.delegate = self
        guard let currentUser = UserService.shared.currentUser else {
            print("PROFILE ERROR: No current user found")
            activities = []
            profileTableView.reloadData()
            return
        }
        if isCurrentUser {
            displayUser = currentUser
        }
        header = ProfileHeaderView(user: displayUser!)
        header?.frame = CGRect(x: 0, y: 0, width: profileTableView.bounds.width, height: 150)
        profileTableView.tableHeaderView = header
        tabBar.onTabSelected = { tab in
            self.selectedTab = tab
            self.profileTableView.reloadData()
        }
        if isCurrentUser {
            header?.onBackTapped = {
                print("SHOULD GO TO EDIT PAGE")
                let storyboard = UIStoryboard(name: "EditProfilePic", bundle: nil)
                let destVC = storyboard.instantiateViewController(withIdentifier: "EditPic") as! EditPicViewController
                destVC.imageView.image = self.header?.avatarButton.imageView?.image
                destVC.saveChanges = { image in
                    self.header?.avatarButton.setImage(image, for: .normal)
                    print("PFP SHOULD BE SAVED: \(self.header?.avatarButton.imageView?.image, default: "SOMETHING WENT WRONG")")
                    let resized = image.preparingThumbnail(of: CGSize(width: 500, height: 500))
                    guard let imageData = resized?.jpegData(compressionQuality: 1) else {
                        print("COULD NOT COMPRESS NEW IMAGE")
                        return
                    }
                    
                    let userName = UserService.shared.currentUser?.name.dropLast(4).replacingOccurrences(of: "@", with: "") ?? "unknown"
                    let ref = Storage.storage().reference().child("profile_pics/\(userName).jpeg")
                    
                    Task {
                        do {
                            _ = try await ref.putDataAsync(imageData)
                            let downloadURL = try await ref.downloadURL()
                            try await UserService.shared.updateProfilePic(uid: UserService.shared.currentUserId!, url: downloadURL.absoluteString)
                            print("Upload succeeded: \(downloadURL.absoluteString)")
                        } catch {
                            print("Upload failed: \(error.localizedDescription)")
                            try? await UserService.shared.updateProfilePic(uid: UserService.shared.currentUserId!, url: DEFAULT_PFP)
                        }
                    }
                }
                //destVC.imageView.image = self.header?.avatarButton.imageView?.image
                //print(destVC.imageView.image)
                self.navigationController?.pushViewController(destVC, animated: true)
            }
        } else {
            header?.onBackTapped = {
                print("PROFILE PIC TAPPED ON NON-CURRENT USER PROFILE")
            }
        }
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        profileTableView.refreshControl = refreshControl
        loadJournal()
        loadFriends()
    }
    
    // sends selected activity to expandVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("ENTERED PROFILE PREPARE")
        if segue.identifier == "ExpandProfile" {
            if let indexPath = profileTableView.indexPathForSelectedRow {
                let selectedItem = activities[indexPath.row]
                let destinationVC = segue.destination as! ExpandReviewVC
                destinationVC.activity = selectedItem
            }
        }
    }
    
    @objc func handleRefresh() {
        loadJournal()
        loadFriends()
    }
    
    func loadJournal() {
        Task {
            do {
                // refresh displayUser first
                if let uid = displayUser?.id {
                    let freshUser = try await UserService.shared.fetchUser(uid: uid)
                    await MainActor.run {
                        self.displayUser = freshUser
                    }
                }
                let fetchedActivities = try await ActivityService.shared.fetchActivities(for: displayUser!.id!)
                await MainActor.run {
                    self.activities = fetchedActivities
                    self.profileTableView.reloadData()
                    self.profileTableView.refreshControl?.endRefreshing()
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
    
    func loadFriends() {
        Task {
            await MainActor.run {
                self.header?.getFriends()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        Task {
                guard let uid = displayUser?.id else { return }
                let freshUser = try await UserService.shared.fetchUser(uid: uid)
            header!.updateUser(freshUser)
            }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !isCurrentUser {
            isCurrentUser = true
        }
        header?.stopSong()
    }

    @objc func friendsTapped() {
        navigationController?.pushViewController(FriendsViewController(), animated: true)
    }

    @objc func settingsTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsVC")
        navigationController?.pushViewController(settingsVC, animated: true)
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
        let activity = activities[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ActivityCell",
            for: indexPath
        ) as! ActivityCellTableViewCell
        
        cell.configure(with: activity, username: displayUser!.name, avatarURL: displayUser!.profilePicURL)
        print("Configuring cell with avatarURL: \(displayUser!.profilePicURL ?? "NIL")")
        return cell
    }
    
}
