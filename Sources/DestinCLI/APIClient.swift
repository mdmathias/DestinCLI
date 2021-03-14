//
//  APIClient.swift
//  DestinyCLI
//
//  Created by Matthew Mathias on 3/13/21.
//

import Foundation

struct APIClient {
    private let apiKey: String
    private let session = URLSession.shared
    private let jsonDecoder = JSONDecoder()
    private(set) var currentPage = 0
    // Use a semaphore to ensure that the command line tool doesn't exit early.
    private let sema = DispatchSemaphore(value: 0)
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    private func request(with urlString: String) -> URLRequest {
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        return request
    }
    
    func searchPlayer(
        displayName: String,
        completion: @escaping (Result<Player, APIClient.Error>) -> Void)
    {
        let urlString = "https://www.bungie.net/Platform/Destiny2/SearchDestinyPlayer/-1/\(displayName)/"
        let req = request(with: urlString)
        let task = session.dataTask(with: req) { (data, response, error) in
            guard let data = data else { return completion(.failure(.noData)) }
            do {
                let playerResponse = try jsonDecoder.decode(
                    SearchPlayerResponse.self,
                    from: data)
                guard let player = playerResponse.response.first else {
                    return completion(.failure(.searchPlayerResponseEmpty))
                }
                completion(.success(player))
            } catch {
                completion(.failure(.failedToDecodePlayer(error)))
            }
            sema.signal()
        }
        task.resume()
        sema.wait()
    }
    
    func getProfile(
        membershipType: Int,
        membershipId: String,
        completion: @escaping (Result<Player.Profile, APIClient.Error>) -> Void)
    {
        let urlString = "https://www.bungie.net/Platform/Destiny2/\(membershipType)/Profile/\(membershipId)/?components=100"
        
        let req = request(with: urlString)
        let task = session.dataTask(with: req) { (data, response, error) in
            guard let data = data else { return completion(.failure(.noData)) }
            do {
                let profile = try jsonDecoder.decode(Player.Profile.self, from: data)
                completion(.success(profile))
            } catch {
                completion(.failure(.failedToDecodeProfile(error)))
            }
            sema.signal()
        }
        task.resume()
        sema.wait()
    }
    
    func activityHistory(
        membershipType: Int,
        membershipId: String,
        characterId: String,
        completion: @escaping (Result<[CruciblePersonalResult], APIClient.Error>) -> Void)
    {
        // TODO: Figure out a way to get the mode in the query string
        // TODO: Figure out a way to keep paging for data until you have it all
        let urlString = "https://www.bungie.net/Platform/Destiny2/\(membershipType)/Account/\(membershipId)/Character/\(characterId)/Stats/Activities/?modes=73&page=\(currentPage)"
        let req = request(with: urlString)
        let task = session.dataTask(with: req) { (data, response, error) in
            guard let data = data else { return completion(.failure(.noData)) }
            do {
                let response = try jsonDecoder.decode(ActivityResponse.self,
                                                      from: data)
                completion(.success(response.activities))
            } catch {
                // If we get here, it could be because we couldn't decode data
                // due to the `currentPage` being set beyond the last valid page
                // (i.e., we're out of data)
                completion(.failure(.failedToDecodeActivities(error)))
            }
            sema.signal()
        }
        task.resume()
        sema.wait()
    }
    
    // TODO: Get character info for a character id
    // https://github.com/vpzed/Destiny2-API-Info/wiki/API-Introduction-Part-2-Account-Concepts#more-api-requests
}

extension APIClient {
    enum Error: Swift.Error {
        case noData
        case searchPlayerResponseEmpty
        case failedToDecodePlayer(Swift.Error)
        case failedToDecodeProfile(Swift.Error)
        case failedToDecodeActivities(Swift.Error)
    }
}
