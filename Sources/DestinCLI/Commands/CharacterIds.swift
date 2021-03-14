//
//  CharacterIds.swift
//  DestinCLI
//
//  Created by Matthew Mathias on 3/13/21.
//

import Foundation
import ArgumentParser

struct CharacterIds: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "A command to retrieve a player's character IDs. These are used to search for activity history for a given character.")
    
    @Option(
        name: .customLong("apikey"),
        help: "The API key to use with the query.")
    var apiKey: String
    
    @Option(name: .long, help: "The membership type to use for the query.")
    var membershipType: Int
    
    @Option(name: .long, help: "The membership ID to use for the query.")
    var membershipId: String
    
    @Flag(name: .short, help: "Show extra logging info for debugging purposes during execution")
    private var verbose: Bool = false
    
    func run() throws {
        if verbose {
            print("Log something useful here.")
        }
        let apiClient = APIClient(apiKey: apiKey)
        apiClient.getProfile(
            membershipType: membershipType,
            membershipId: membershipId) { result in
            switch result {
            case let .success(profile):
                print("Found player character IDs: \(profile.characterIDs)")
            case let .failure(error):
                print("Failed to get character IDs with error: \(error)")
            }
        }
    }
}
