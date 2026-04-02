//
//  MusicMethods.swift
//  AudioAudit
//
//  Created by Brett Sestak on 3/10/26.
//

import Foundation
import MusicKit
import UIKit

// This function returns the first song search result based off the title string
// Note that a lot of info is contained in Song, so there's a lot of data that can be grabbed
func searchSong(title: String) async throws -> Song? {
    var request = MusicCatalogSearchRequest(term: title, types: [Song.self])
    request.limit = 1
    let response = try await request.response()
    // the song
    return response.songs.first
}

// This gets the first result off of Apple Music and returns a UIImage of the album art. Note,
// that if no width or height is selected, then it defaults to 500 x 500.
func getAlbumArt(songTitle: String, width: Int = 500, height: Int = 500) async throws -> UIImage? {
    guard let song = try await searchSong(title: songTitle) else { return nil }
    guard let url = song.artwork?.url(width: width, height: height) else { return nil }
    let (data, _) = try await URLSession.shared.data(from: url)
    print(UIImage(data: data) as Any)
    return UIImage(data: data)
}

// This function returns a tuple that contains a song's artist, album, and cover art
func getSongInfo(title: String, artist: String) async throws -> (artist: String, album: String, artwork: UIImage?)? {
    let query = "\(title) \(artist)"
    guard let song = try await searchSong(title: query) else { return nil }

    var image: UIImage? = nil
    if let url = song.artwork?.url(width: 500, height: 500) {
        let (data, _) = try await URLSession.shared.data(from: url)
        image = UIImage(data: data)
    }

    return (song.artistName, song.albumTitle ?? "", image)
}
