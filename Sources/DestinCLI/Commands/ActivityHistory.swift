//
//  ActivityHistory.swift
//  DestinCLI
//
//  Created by Matthew Mathias on 3/13/21.
//

import Foundation
import ArgumentParser

struct ActivityHistory: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "A command to retrieve a player's activity history for a given character in a given mode.")
    
    @Option(
        name: .customLong("apikey"),
        help: "The API key to use with the query.")
    var apiKey: String
    
    @Option(name: .long, help: "The membership type to use for the query.")
    var membershipType: Int
    
    @Option(name: .long, help: "The membership ID to use for the query.")
    var membershipId: String
    
    @Option(
      name: .long,
      help: "The character ID to use when searching for PvP activities.")
    var characterId: String
    
    @Flag(name: .short, help: "Show extra logging info for debugging purposes during execution")
    private var verbose: Bool = false
    
    func run() throws {
        if verbose {
            print("Searching for activity history for player...")
        }
        
        let apiClient = APIClient(apiKey: apiKey)
        apiClient.activityHistory(
            membershipType: membershipType,
            membershipId: membershipId,
            characterId: characterId) { result in
            switch result {
            case let .success(history):
                print("Found activity history: \(history)")
            case let .failure(error):
                print("Failed to get activity history with error: \(error)")
            }
        }
    }
}
