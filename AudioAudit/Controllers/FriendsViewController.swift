//
//  FriendsViewController.swift
//  AudioAudit
//

import UIKit

final class FriendsViewController: UITableViewController {

    private var friends: [AAUser] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Friends"
        view.backgroundColor = .systemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FriendCell")

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "person.badge.plus"),
                            style: .plain, target: self, action: #selector(addFriendTapped)),
            UIBarButtonItem(image: UIImage(systemName: "tray.and.arrow.down"),
                            style: .plain, target: self, action: #selector(requestsTapped))
        ]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFriends()
    }

    @objc private func addFriendTapped() {
        navigationController?.pushViewController(AddFriendViewController(), animated: true)
    }

    @objc private func requestsTapped() {
        navigationController?.pushViewController(FriendRequestsViewController(), animated: true)
    }

    private func loadFriends() {
        guard let uid = UserService.shared.currentUserId else { return }
        Task {
            do {
                let users = try await UserService.shared.fetchFriends(of: uid)
                await MainActor.run {
                    self.friends = users.sorted { $0.name.lowercased() < $1.name.lowercased() }
                    self.tableView.reloadData()
                }
            } catch {
                print("Error loading friends: \(error.localizedDescription)")
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.isEmpty ? 1 : friends.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        if friends.isEmpty {
            config.text = "No friends yet"
            config.secondaryText = "Tap + to add some"
            config.textProperties.color = .secondaryLabel
            cell.selectionStyle = .none
        } else {
            let friend = friends[indexPath.row]
            config.text = friend.name
            config.secondaryText = friend.email
            config.image = UIImage(systemName: "person.crop.circle")
            cell.selectionStyle = .default
        }
        cell.contentConfiguration = config
        return cell
    }
}
