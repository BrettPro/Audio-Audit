//
//  ITunesMethods.swift
//  AudioAudit
//
//  Created by Brett Sestak on 4/1/26.
//

import Foundation
import UIKit

// MARK: - Structs for decoding iTunes JSON
struct ITunesSearchResult: Codable {
    let resultCount: Int
    let results: [ITunesSong]
}

struct ITunesSong: Codable {
    let trackName: String?
    let artistName: String?
    let collectionName: String?
    let artworkUrl100: String? // 100x100 image
}

// MARK: - Fetch song info from iTunes
func getSongInfoFromITunes(title: String) async throws -> (artist: String, album: String, artwork: UIImage?)? {
    // Prepare URL
    guard let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let url = URL(string: "https://itunes.apple.com/search?term=\(encodedTitle)&media=music&limit=1") else {
        return nil
    }
    
    // Fetch data
    let (data, _) = try await URLSession.shared.data(from: url)
    
    // Decode JSON
    let searchResult = try JSONDecoder().decode(ITunesSearchResult.self, from: data)
    guard let song = searchResult.results.first else { return nil }
    
    // Load artwork
    var image: UIImage? = nil
    if let artworkUrl = song.artworkUrl100,
       let url = URL(string: artworkUrl) {
        let (imageData, _) = try await URLSession.shared.data(from: url)
        image = UIImage(data: imageData)
    }
    
    return (song.artistName ?? "", song.collectionName ?? "", image)
}
