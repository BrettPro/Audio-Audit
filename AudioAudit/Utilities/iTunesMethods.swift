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
func getSongInfoFromITunes(title: String, artist: String) async throws -> (artist: String, album: String, artwork: UIImage?)? {
    
    // Stronger query (title + artist)
    let query = "\(title) \(artist)"
    
    guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let url = URL(string: "https://itunes.apple.com/search?term=\(encoded)&media=music&entity=song&limit=10") else {
        return nil
    }
    
    let (data, _) = try await URLSession.shared.data(from: url)
    let searchResult = try JSONDecoder().decode(ITunesSearchResult.self, from: data)
    
    guard !searchResult.results.isEmpty else { return nil }
    
    let normalizedArtist = artist.lowercased()
    let normalizedTitle = title.lowercased()
    
    // Better match: prioritize both artist AND title match
    let song = searchResult.results.first(where: {
        let resultArtist = $0.artistName?.lowercased() ?? ""
        let resultTitle = $0.trackName?.lowercased() ?? ""
        
        return resultArtist.contains(normalizedArtist) &&
               resultTitle.contains(normalizedTitle)
    }) ?? searchResult.results.first
    
    guard let song else { return nil }
    
    // High-res artwork
    var image: UIImage? = nil
    if let artworkUrl = song.artworkUrl100 {
        let highRes = artworkUrl.replacingOccurrences(of: "100x100", with: "600x600")
        if let url = URL(string: highRes) {
            let (imageData, _) = try await URLSession.shared.data(from: url)
            image = UIImage(data: imageData)
        }
    }
    
    return (song.artistName ?? "", song.collectionName ?? "", image)
}
