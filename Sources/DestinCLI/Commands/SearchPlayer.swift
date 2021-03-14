//
//  ProfileCommand.swift
//  DestinCLI
//
//  Created by Matthew Mathias on 3/13/21.
//

import ArgumentParser
import Foundation

struct SearchPlayer: ParsableCommand {
    public static let configuration = CommandConfiguration(abstract: "A command to retrieve player information for a given API key and player name. The player name is the display name seen on Destiny.")

    @Option(
        name: .customLong("apikey"),
        help: "The API key to use in querying bungie.net")
    private var apiKey: String

    @Option(
        name: .customLong("playername"),
        help: "The player name to use in the query.")
    private var playerName: String

    @Flag(name: .short, help: "Show extra logging info for debugging purposes during execution")
    private var verbose: Bool = false

    func run() throws {
        if verbose {
            print("Fetching profile information for \(playerName)")
        }
        let apiClient = APIClient(apiKey: apiKey)
        apiClient.searchPlayer(displayName: playerName) { result in
            switch result {
            case let .success(player):
                print("Successfully found player: \(player)")
            case let .failure(error):
                print("Failed to find player with error: \(error)")
            }
        }
    }
}
