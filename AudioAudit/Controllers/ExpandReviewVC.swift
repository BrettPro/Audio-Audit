//
//  ExpandReviewVC.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 4/14/26.
//

import UIKit

class ExpandReviewVC: UIViewController {

    var activity: Activity?
    var username: String?
    var avatarURL: String?
    
    let activityView = ActivityCellTableViewCell(style: .default, reuseIdentifier: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            do {
                let reviewUser = try await UserService.shared.fetchUser(uid: activity!.userId)
                await MainActor.run {
                    username = reviewUser.name
                    avatarURL = reviewUser.profilePicURL
                    setupActivity()
                }
            } catch {
                print("Failed to fetch user: \(error)")
                await MainActor.run {
                    setupActivity()
                }
            }
        }
        view.backgroundColor = .systemBackground
    }
    
    private func setupActivity() {
        guard let activity = activity else {
            return
        }
        
        activityView.configure(with: activity, username: username, avatarURL: avatarURL)
        activityView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(activityView)
        
        activityView.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            activityView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            activityView.contentView.topAnchor.constraint(equalTo: activityView.topAnchor),
            activityView.contentView.leadingAnchor.constraint(equalTo: activityView.leadingAnchor),
            activityView.contentView.trailingAnchor.constraint(equalTo: activityView.trailingAnchor),
            activityView.contentView.bottomAnchor.constraint(equalTo: activityView.bottomAnchor),
        ])
        
    }
    
    

}
