//
//  AddActivityViewController.swift
//  AudioAudit
//
//  Created by Bersam Basagaoglu on 3/11/26.
//

import UIKit
import MusicKit

class AddActivityViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var formScrollView: UIScrollView!
    @IBOutlet weak var albumArtImageView: UIImageView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var ratingSegment: UISegmentedControl!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!

    var searchResults: [Song] = []
    var usingSamples = false
    var filteredSamples: [SampleSong] = []

    var selectedSong: String?
    var selectedArtist: String?
    var selectedArtwork: UIImage?

    struct SampleSong {
        let title: String
        let artist: String
    }

    let sampleSongs: [SampleSong] = [
        SampleSong(title: "Bohemian Rhapsody", artist: "Queen"),
        SampleSong(title: "Blinding Lights", artist: "The Weeknd"),
        SampleSong(title: "Shape of You", artist: "Ed Sheeran"),
        SampleSong(title: "Levitating", artist: "Dua Lipa"),
        SampleSong(title: "Bad Guy", artist: "Billie Eilish"),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        requestMusicAuth()
        loadSamples()
    }

    func requestMusicAuth() {
        Task {
            let status = await MusicAuthorization.request()
            if status != .authorized {
                print("MusicKit not authorized")
            }
        }
    }

    // MARK: - View Toggling

    func showSearch() {
        searchBar.isHidden = false
        resultsTableView.isHidden = false
        formScrollView.isHidden = true
    }

    func showForm() {
        searchBar.isHidden = true
        resultsTableView.isHidden = true
        formScrollView.isHidden = false
        songLabel.text = selectedSong
        artistLabel.text = selectedArtist
        albumArtImageView.image = selectedArtwork
    }

    // MARK: - Search

    func loadSamples() {
        usingSamples = true
        filteredSamples = sampleSongs
        resultsTableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let query = searchBar.text, !query.isEmpty else { return }

        Task {
            do {
                var request = MusicCatalogSearchRequest(term: query, types: [Song.self])
                request.limit = 15
                let response = try await request.response()
                await MainActor.run {
                    if response.songs.isEmpty {
                        self.usingSamples = true
                        self.filteredSamples = self.sampleSongs.filter {
                            $0.title.localizedCaseInsensitiveContains(query) ||
                            $0.artist.localizedCaseInsensitiveContains(query)
                        }
                        if self.filteredSamples.isEmpty {
                            self.filteredSamples = self.sampleSongs
                        }
                    } else {
                        self.usingSamples = false
                        self.searchResults = Array(response.songs)
                    }
                    self.resultsTableView.reloadData()
                }
            } catch {
                print("Search error: \(error)")
                await MainActor.run {
                    self.usingSamples = true
                    self.filteredSamples = self.sampleSongs
                    self.resultsTableView.reloadData()
                }
            }
        }
    }

    // MARK: - Table View

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usingSamples ? filteredSamples.count : searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongResult", for: indexPath)
        var config = cell.defaultContentConfiguration()
        if usingSamples {
            let sample = filteredSamples[indexPath.row]
            config.text = sample.title
            config.secondaryText = sample.artist
        } else {
            let song = searchResults[indexPath.row]
            config.text = song.title
            config.secondaryText = song.artistName
        }
        cell.contentConfiguration = config
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if usingSamples {
            let sample = filteredSamples[indexPath.row]
            selectedSong = sample.title
            selectedArtist = sample.artist
            selectedArtwork = nil
            showForm()
        } else {
            let song = searchResults[indexPath.row]
            selectedSong = song.title
            selectedArtist = song.artistName

            Task {
                var image: UIImage? = nil
                if let url = song.artwork?.url(width: 500, height: 500) {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    image = UIImage(data: data)
                }
                await MainActor.run {
                    self.selectedArtwork = image
                    self.showForm()
                }
            }
        }
    }

    // MARK: - Actions

    @IBAction func cancelTapped() {
        dismiss(animated: true)
    }

    @IBAction func changeSongTapped() {
        showSearch()
    }
    
    @IBAction func submitTapped() {
        guard let song = selectedSong, let artist = selectedArtist,
              let uid = UserService.shared.currentUserId else { return }

        let reviewText = reviewTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let rating = ratingSegment.selectedSegmentIndex + 1
        let review = (reviewText?.isEmpty == false) ? reviewText : nil

        submitButton.isEnabled = false

        Task {
            do {
                _ = try await ActivityService.shared.logReview(
                    userId: uid,
                    song: song,
                    artist: artist,
                    rating: rating,
                    review: review
                )

                await MainActor.run {
                    self.dismiss(animated: true)
                }
            } catch {
                print("Failed to submit activity: \(error)")
                await MainActor.run {
                    self.submitButton.isEnabled = true
                    let alert = UIAlertController(title: "Error", message: "Failed to submit. Try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
