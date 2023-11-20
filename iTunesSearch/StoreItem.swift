//
//  StoreItem.swift
//  iTunesSearch
//
//  Created by Tyler May on 10/30/23.
//

import Foundation

struct StoreItem: Codable {
    var name: String
    var artist: String
    var kind: String
    var artworkURL: String
    
    enum CodingKeys: String, CodingKey {
        case name = "trackName"
        case artist = "artistName"
        case kind
        case artworkURL = "artworkUrl100"
    }
}
