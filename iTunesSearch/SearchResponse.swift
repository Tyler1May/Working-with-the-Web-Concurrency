//
//  SearchResponse.swift
//  iTunesSearch
//
//  Created by Tyler May on 10/30/23.
//

import Foundation

struct SearchResponse: Codable {
    var results: [StoreItem]
}
