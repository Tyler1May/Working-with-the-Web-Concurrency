//
//  ItemController.swift
//  iTunesSearch
//
//  Created by Tyler May on 10/30/23.
//

import Foundation

class ItemController {
    
    static let shared = ItemController()
    
    enum ItemContollerError: Error, LocalizedError {
        case cannotFindSearchItems
    }
    
    func fetchItems(matching query: [URLQueryItem]) async throws -> [StoreItem] {
        var components = URLComponents(string: "https://itunes.apple.com/search")!
        components.queryItems = query
        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw ItemContollerError.cannotFindSearchItems
        }
        let results = try JSONDecoder().decode(SearchResponse.self, from: data)
        return results.results
    }
}
