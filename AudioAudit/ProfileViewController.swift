//
//  ProfileViewController.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 3/2/26.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addSampleReview()
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
