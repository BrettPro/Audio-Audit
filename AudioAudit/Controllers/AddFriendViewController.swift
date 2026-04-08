//
//  AddFriendViewController.swift
//  AudioAudit
//

import UIKit

final class AddFriendViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    private let searchBar = UISearchBar()
    private let tableView = UITableView()

    private var results: [AAUser] = []
    private var sentRequestUids: Set<String> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Friend"
        view.backgroundColor = .systemBackground

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search by name"
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        searchBar.delegate = self
        view.addSubview(searchBar)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPendingOutgoing()
    }

    private func loadPendingOutgoing() {
        guard let uid = UserService.shared.currentUserId else { return }
        Task {
            do {
                let outgoing = try await FriendService.shared.fetchOutgoingRequests(for: uid)
                await MainActor.run {
                    self.sentRequestUids = Set(outgoing.map { $0.toUid })
                    self.tableView.reloadData()
                }
            } catch {
                print("Failed to load outgoing requests: \(error.localizedDescription)")
            }
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let query = searchBar.text, !query.isEmpty else { return }
        runSearch(prefix: query)
    }

    private func runSearch(prefix: String) {
        Task {
            do {
                let users = try await UserService.shared.searchUsers(byNamePrefix: prefix)
                let myUid = UserService.shared.currentUserId
                let myFriends = Set(UserService.shared.currentUser?.friends ?? [])
                let filtered = users.filter { user in
                    guard let id = user.id else { return false }
                    if id == myUid { return false }
                    if myFriends.contains(id) { return false }
                    return true
                }
                await MainActor.run {
                    self.results = filtered
                    self.tableView.reloadData()
                }
            } catch {
                print("Search failed: \(error.localizedDescription)")
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        let user = results[indexPath.row]

        var config = cell.defaultContentConfiguration()
        config.text = user.name
        config.secondaryText = user.email
        config.image = UIImage(systemName: "person.crop.circle")
        cell.contentConfiguration = config
        cell.selectionStyle = .none

        let button = UIButton(type: .system)
        let alreadySent = sentRequestUids.contains(user.id ?? "")
        button.setTitle(alreadySent ? "Requested" : "Add", for: .normal)
        button.isEnabled = !alreadySent
        button.frame = CGRect(x: 0, y: 0, width: 80, height: 32)
        button.addAction(UIAction { [weak self] _ in
            self?.sendRequest(to: user, button: button)
        }, for: .touchUpInside)
        cell.accessoryView = button

        return cell
    }

    private func sendRequest(to user: AAUser, button: UIButton) {
        guard let me = UserService.shared.currentUserId, let to = user.id else { return }
        button.isEnabled = false
        Task {
            do {
                try await FriendService.shared.sendRequest(from: me, to: to)
                await MainActor.run {
                    self.sentRequestUids.insert(to)
                    button.setTitle("Requested", for: .normal)
                }
            } catch {
                print("Send request failed: \(error.localizedDescription)")
                await MainActor.run { button.isEnabled = true }
            }
        }
    }
}
