//
//  SettingsViewController.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 3/2/26.
//

import UIKit
import FirebaseAuth
import UserNotifications

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    enum SettingsSection: Int, CaseIterable {
        case appearance, preferences, integrations, account
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    // MARK: - Sections

    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch SettingsSection(rawValue: section)! {
        case .appearance: return 1
        case .preferences: return 3
        case .integrations: return 1
        case .account: return 1
        }
    }

    // MARK: - Cells

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)

        switch SettingsSection(rawValue: indexPath.section)! {

        case .appearance:
            let isDarkMode = UserDefaults.standard.bool(forKey: "darkMode")

            cell.textLabel?.text = "Dark Mode"
            cell.imageView?.image = UIImage(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")

            let toggle = UISwitch()
            toggle.isOn = isDarkMode
            toggle.addTarget(self, action: #selector(darkModeChanged(_:)), for: .valueChanged)
            cell.accessoryView = toggle

        case .preferences:
            if indexPath.row == 0 {
                cell.textLabel?.text = "Show Activity in Map"
                cell.imageView?.image = UIImage(systemName: "map.fill")

                let toggle = UISwitch()
                toggle.isOn = UserDefaults.standard.bool(forKey: "showMap")
                toggle.addTarget(self, action: #selector(mapChanged(_:)), for: .valueChanged)
                cell.accessoryView = toggle
            }
            else if indexPath.row == 1 {
                cell.textLabel?.text = "Font Size"
                cell.imageView?.image = UIImage(systemName: "textformat.size")
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.textLabel?.text = "Profile Song"
                cell.imageView?.image = UIImage(systemName: "music.note")
                cell.accessoryType = .disclosureIndicator
            }

        case .integrations:
            cell.textLabel?.text = "Notifications"

            let center = UNUserNotificationCenter.current()
            center.getNotificationSettings { settings in
                DispatchQueue.main.async {
                    let allowed = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional

                    cell.detailTextLabel?.text = allowed ? "Allowed" : "Not Allowed"
                    cell.imageView?.image = UIImage(systemName: allowed ? "bell.fill" : "bell.slash.fill")

                    cell.setNeedsLayout()
                }
            }

            cell.accessoryType = .none

        case .account:
            cell.textLabel?.text = "Log Out"
            cell.textLabel?.textColor = .systemRed
            cell.textLabel?.textAlignment = .center
        }

        return cell
    }

    // MARK: - Tap Handling

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch SettingsSection(rawValue: indexPath.section)! {

        case .preferences:
            if indexPath.row == 1 {
                performSegue(withIdentifier: "goToFontSize", sender: nil)
            }
            else if indexPath.row == 2 {
                let vc = ProfileSongPickerViewController()
                navigationController?.pushViewController(vc, animated: true)
            }
        
        case .integrations:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }

        case .account:
            showLogoutAlert()

        default:
            break
        }
    }

    // MARK: - Actions

    @objc func darkModeChanged(_ sender: UISwitch) {
        view.window?.overrideUserInterfaceStyle = sender.isOn ? .dark : .light
        UserDefaults.standard.set(sender.isOn, forKey: "darkMode")

        // reload appearance section to update icon
        tableView.reloadSections(IndexSet(integer: SettingsSection.appearance.rawValue), with: .none)
    }

    @objc func mapChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "showMap")
    }

    // MARK: - Logout

    func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive) { _ in
            UserService.shared.clearCurrentUser()
            try? Auth.auth().signOut()

            if let window = self.view.window {
                window.rootViewController = UIStoryboard(name: "Main", bundle: nil)
                    .instantiateInitialViewController()
                window.makeKeyAndVisible()
            }
        }

        alert.addAction(cancelAction)
        alert.addAction(logoutAction)

        present(alert, animated: true)
    }
}
