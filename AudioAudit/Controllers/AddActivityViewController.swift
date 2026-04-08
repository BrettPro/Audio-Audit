//
//  AddActivityViewController.swift
//  AudioAudit
//
//  Created by Bersam Basagaoglu on 3/11/26.
//

import UIKit
import MusicKit
import CoreLocation

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
    @IBOutlet weak var locationButton: UIButton!
    
    var searchResults: [Song] = []
    var usingSamples = false
    var filteredSamples: [SampleSong] = []

    var selectedSong: String?
    var selectedArtist: String?
    var selectedArtwork: UIImage?
    var selectedCoord: CLLocationCoordinate2D?

    struct SampleSong {
        let title: String
        let artist: String
    }
    
    struct Song {
        let title: String
        let artistName: String
        let artworkUrl: String?  // optional URL string for album art
    }
    
    struct ITunesSong: Codable {
        let trackName: String
        let artistName: String
        let artworkUrl100: String?
    }

    struct ITunesSearchResponse: Codable {
        let results: [ITunesSong]
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
                let results = try await searchITunes(query: query)
                await MainActor.run {
                    if results.isEmpty {
                        // fallback to your sample songs
                        self.usingSamples = true
                        self.filteredSamples = self.sampleSongs.filter {
                            $0.title.localizedCaseInsensitiveContains(query) ||
                            $0.artist.localizedCaseInsensitiveContains(query)
                        }
                    } else {
                        self.usingSamples = false
                        // Convert ITunesSong to your Song-like struct
                        self.searchResults = results.map { song in
                            Song(title: song.trackName, artistName: song.artistName, artworkUrl: song.artworkUrl100)
                        }
                    }
                    self.resultsTableView.reloadData()
                }
            } catch {
                print("iTunes search failed: \(error)")
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
            config.image = UIImage(systemName: "music.note")
        } else {
            let song = searchResults[indexPath.row]
            config.text = song.title
            config.secondaryText = song.artistName
            config.image = UIImage(systemName: "music.note")
            
            // Async load album art
            if let artworkUrl = song.artworkUrl, let url = URL(string: artworkUrl) {
                Task {
                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        if let image = UIImage(data: data) {
                            await MainActor.run {
                                // Ensure the cell is still visible before setting the image
                                if let visibleCell = tableView.cellForRow(at: indexPath) {
                                    var updatedConfig = visibleCell.defaultContentConfiguration()
                                    updatedConfig.text = song.title
                                    updatedConfig.secondaryText = song.artistName
                                    updatedConfig.image = image
                                    updatedConfig.imageProperties.maximumSize = CGSize(width: 50, height: 50)
                                    updatedConfig.imageProperties.cornerRadius = 4
                                    visibleCell.contentConfiguration = updatedConfig
                                }
                            }
                        }
                    } catch {
                        print("Failed to load artwork: \(error)")
                    }
                }
            }
        }
        
        // Set size and corner radius for the image
        config.imageProperties.maximumSize = CGSize(width: 50, height: 50)
        config.imageProperties.cornerRadius = 4
        
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
                if let urlString = song.artworkUrl, let url = URL(string: urlString) {
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
    
    @IBAction func locationPressed(_ sender: Any) {
        let locPicker = ReviewLocationPickerViewController()
            locPicker.modalPresentationStyle = .fullScreen
            locPicker.onConfirm = { coord in
                self.selectedCoord = coord
                Task {
                    await MainActor.run {
                        self.locationButton.setTitle("Location Set", for: .normal)
                    }
                }
                print(self.selectedCoord)
            }
            present(locPicker, animated: true)
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
        let lat = selectedCoord?.latitude
        let lon = selectedCoord?.longitude
        Task {
            do {
                _ = try await ActivityService.shared.logReview(
                    userId: uid,
                    song: song,
                    artist: artist,
                    rating: rating,
                    review: review,
                    latitude: lat,
                    longitude: lon
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

    func searchITunes(query: String) async throws -> [ITunesSong] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://itunes.apple.com/search?term=\(encodedQuery)&entity=song&limit=20"
        guard let url = URL(string: urlString) else { return [] }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ITunesSearchResponse.self, from: data)
        return response.results
    }
}
