//
//  TrackObject.swift
//  spotifymini
//
//  Created by admin on 4/6/23.
//

import Foundation

struct SpotifyItem: Codable {
    var item: Item
    var is_playing: Bool
}

struct Item: Codable {
    var name: String
    var popularity: Int
    var id: String
    var album: Album
    var artists: [Artist]
}

struct Album: Codable {
    var name: String
    var images: [ArtistImage]
}

struct ArtistImage: Codable {
    var height: Int
    var url: String
    var width: Int
}

struct Artist: Codable {
    var name: String
    var id: String
}

struct Artists: Codable {
    var artists: [Artist]
}

struct Track: Codable {
    var track: String
    var release_date: String
}
