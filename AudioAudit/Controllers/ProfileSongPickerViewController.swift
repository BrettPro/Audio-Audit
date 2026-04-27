//
//  ProfileSongPickerViewController.swift
//  AudioAudit
//
//  Created by Brett Sestak on 4/21/26.
//

import Foundation
import UIKit

class ProfileSongPickerViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    let searchBar = UISearchBar()
    let tableView = UITableView()

    struct Song {
        let title: String
        let artist: String
        let previewURL: String?
        let artworkURL: String?
    }

    struct ITunesSong: Codable {
        let trackName: String
        let artistName: String
        let previewUrl: String?
        let artworkUrl100: String?
    }

    struct Response: Codable {
        let results: [ITunesSong]
    }

    var results: [Song] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Choose Song"
        view.backgroundColor = .systemBackground

        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(searchBar)
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

    // MARK: - Search

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let query = searchBar.text, !query.isEmpty else { return }

        Task {
            let songs = try await searchITunes(query: query)
            await MainActor.run {
                self.results = songs.map {
                    Song(title: $0.trackName, artist: $0.artistName, previewURL: $0.previewUrl, artworkURL: $0.artworkUrl100)
                }
                self.tableView.reloadData()
            }
        }
    }

    func searchITunes(query: String) async throws -> [ITunesSong] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "https://itunes.apple.com/search?term=\(encoded)&entity=song&limit=20")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(Response.self, from: data).results
    }

    // MARK: - Table

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let song = results[indexPath.row]
        cell.textLabel?.text = song.title
        cell.detailTextLabel?.text = song.artist
        cell.imageView?.image = UIImage(systemName: "music.note")
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        cell.imageView?.layer.cornerRadius = 4
        cell.imageView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        if let urlString = song.artworkURL,
           let url = URL(string: urlString) {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let image = UIImage(data: data) {

                        await MainActor.run {
                            if let visibleCell = tableView.cellForRow(at: indexPath) {
                                visibleCell.imageView?.image = image
                                visibleCell.setNeedsLayout()
                            }
                        }
                    }
                } catch {
                    print("Failed to load artwork:", error)
                }
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let song = results[indexPath.row]

        guard let uid = UserService.shared.currentUserId else { return }

        Task {
            try await UserService.shared.updateProfileSong(
                uid: uid,
                title: song.title,
                artist: song.artist,
                previewURL: song.previewURL
            )

            // refresh cached user
            try await UserService.shared.loadCurrentUser()

            await MainActor.run {
                self.navigationController?.popViewController(animated: true)
            }
        }
        

    }
}
