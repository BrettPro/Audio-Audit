//
//  FriendRequestsViewController.swift
//  AudioAudit
//

import UIKit

final class FriendRequestsViewController: UITableViewController {

    private var incoming: [FriendRequest] = []
    private var outgoing: [FriendRequest] = []
    private var userCache: [String: AAUser] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Requests"
        view.backgroundColor = .systemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RequestCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRequests()
    }

    private func loadRequests() {
        guard let uid = UserService.shared.currentUserId else { return }
        Task {
            do {
                async let inc = FriendService.shared.fetchIncomingRequests(for: uid)
                async let out = FriendService.shared.fetchOutgoingRequests(for: uid)
                let (incomingResult, outgoingResult) = try await (inc, out)

                let uids = Set(incomingResult.map { $0.fromUid } + outgoingResult.map { $0.toUid })
                let users = try await UserService.shared.fetchUsers(uids: Array(uids))

                await MainActor.run {
                    self.incoming = incomingResult
                    self.outgoing = outgoingResult
                    self.userCache = users
                    self.tableView.reloadData()
                }
            } catch {
                print("Error loading requests: \(error.localizedDescription)")
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 2 }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Incoming" : "Outgoing"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return max(incoming.count, 1) }
        return max(outgoing.count, 1)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath)
        cell.accessoryView = nil
        cell.selectionStyle = .none
        var config = cell.defaultContentConfiguration()

        if indexPath.section == 0 {
            if incoming.isEmpty {
                config.text = "No incoming requests"
                config.textProperties.color = .secondaryLabel
                cell.contentConfiguration = config
                return cell
            }
            let req = incoming[indexPath.row]
            let name = userCache[req.fromUid]?.name ?? req.fromUid
            config.text = name
            config.secondaryText = "wants to be friends"
            cell.contentConfiguration = config
            cell.accessoryView = makeIncomingButtons(for: req)
        } else {
            if outgoing.isEmpty {
                config.text = "No outgoing requests"
                config.textProperties.color = .secondaryLabel
                cell.contentConfiguration = config
                return cell
            }
            let req = outgoing[indexPath.row]
            let name = userCache[req.toUid]?.name ?? req.toUid
            config.text = name
            config.secondaryText = "Requested"
            cell.contentConfiguration = config
            cell.accessoryView = makeCancelButton(for: req)
        }

        return cell
    }

    private func makeIncomingButtons(for request: FriendRequest) -> UIView {
        let accept = UIButton(type: .system)
        accept.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        accept.tintColor = .systemGreen
        accept.addAction(UIAction { [weak self] _ in self?.accept(request) }, for: .touchUpInside)

        let deny = UIButton(type: .system)
        deny.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        deny.tintColor = .systemRed
        deny.addAction(UIAction { [weak self] _ in self?.deny(request) }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [accept, deny])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.frame = CGRect(x: 0, y: 0, width: 72, height: 32)
        return stack
    }

    private func makeCancelButton(for request: FriendRequest) -> UIView {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.tintColor = .systemRed
        button.frame = CGRect(x: 0, y: 0, width: 70, height: 32)
        button.addAction(UIAction { [weak self] _ in self?.cancel(request) }, for: .touchUpInside)
        return button
    }

    private func accept(_ request: FriendRequest) {
        Task {
            do {
                try await FriendService.shared.acceptRequest(from: request.fromUid, to: request.toUid)
                // Refresh local cached current user friends list
                try? await UserService.shared.loadCurrentUser()
                await MainActor.run { self.loadRequests() }
            } catch {
                print("Accept failed: \(error.localizedDescription)")
            }
        }
    }

    private func deny(_ request: FriendRequest) {
        Task {
            do {
                try await FriendService.shared.denyRequest(from: request.fromUid, to: request.toUid)
                await MainActor.run { self.loadRequests() }
            } catch {
                print("Deny failed: \(error.localizedDescription)")
            }
        }
    }

    private func cancel(_ request: FriendRequest) {
        Task {
            do {
                try await FriendService.shared.cancelRequest(from: request.fromUid, to: request.toUid)
                await MainActor.run { self.loadRequests() }
            } catch {
                print("Cancel failed: \(error.localizedDescription)")
            }
        }
    }
}
