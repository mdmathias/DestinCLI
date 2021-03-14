//
//  Player.swift
//  DestinyCLT
//
//  Created by Matthew Mathias on 3/13/21.
//

import Foundation

struct SearchPlayerResponse: Decodable {
    let response: [Player]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SearchPlayerResponse.CodingKeys.self)
        self.response = try container.decode([Player].self, forKey: .response)
    }
}

extension SearchPlayerResponse {
    enum CodingKeys: String, CodingKey {
        case response = "Response"
    }
}

struct Player: Decodable {
    let membershipType: Int
    let membershipId: String
    let displayName: String
}

extension Player: CustomStringConvertible {
    var description: String {
        return "\(displayName) has membership type \(membershipType) and ID \(membershipId)"
    }
}

extension Player {
    struct Profile: Decodable {
        let characterIDs: [Int]
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Profile.CodingKeys.self)
            let response = try container.nestedContainer(keyedBy: Profile.CodingKeys.self,
                                                         forKey: .response)
            let profile = try response.nestedContainer(keyedBy: Profile.CodingKeys.self,
                                                        forKey: .profile)
            let data = try profile.nestedContainer(keyedBy: Profile.CodingKeys.self,
                                                   forKey: .data)
            self.characterIDs = try data.decode([Int].self, forKey: .characterIds)
        }
    }
}

extension Player.Profile {
    enum CodingKeys: String, CodingKey {
        case response = "Response"
        case profile
        case data
        case characterIds
    }
}

struct CharacterInfo: Decodable {
    let characterId: String
    let classType: Int
    let raceType: Int
    let genderType: Int
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CharacterInfo.CodingKeys.self)
        let response = try container.nestedContainer(keyedBy: CharacterInfo.CodingKeys.self,
                                                     forKey: .response)
        let character = try response.nestedContainer(keyedBy: CharacterInfo.CodingKeys.self,
                                                     forKey: .character)
        let data = try character.nestedContainer(keyedBy: CharacterInfo.CodingKeys.self,
                                                 forKey: .data)
        self.characterId = try data.decode(String.self, forKey: .characterId)
        self.classType = try data.decode(Int.self, forKey: .classType)
        self.raceType = try data.decode(Int.self, forKey: .raceType)
        self.genderType = try data.decode(Int.self, forKey: .genderType)
    }
}

extension CharacterInfo {
    enum CodingKeys: String, CodingKey {
        case response = "Response"
        case character
        case data
        case characterId
        case classType
        case raceType
        case genderType
    }
}
