//
//  Activity.swift
//  DestinyCLI
//
//  Created by Matthew Mathias on 3/13/21.
//

import Foundation

/* Activity history form
 /Destiny2/{membershipType}/Account/{destinyMembershipId}/Character/{characterId}/Stats/Activities/
 */

/*
 This will get paginated activity history for control quickplay on my hunter
 https://www.bungie.net/Platform/Destiny2/2/Account/4611686018429228779/Character/2305843009265124742/Stats/Activities/?modes=73&page=10
 
 Hunter ID comes from GetProfile
 https://bungie-net.github.io/multi/operation_get_Destiny2-GetProfile.html#operation_get_Destiny2-GetProfile
 */

/*
 Activity history will give you an `instanceId` you can use in the post game carnage report to get the summary of the crucible match
 
 https://www.bungie.net/Platform/Destiny2/Stats/PostGameCarnageReport/{activityId}/
 */

struct ActivityResponse: Decodable {
    let activities: [CruciblePersonalResult]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let response = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .response)
        self.activities = try response.decode([CruciblePersonalResult].self,
                                              forKey: .activities)
    }
    
    enum CodingKeys: String, CodingKey {
        case response = "Response"
        case activities
    }
}

struct ActivityDetails: Codable {
    let referenceId: Int
    let directorActivityHash: Int
    let instanceId: String
    let mode: Int
    let modes: [Int]
    let isPrivate: Bool
    let membershipType: Int
}

struct Basic: Codable {
    let value: Double
}

struct Values: Codable {
    static func decode<T>(fromContainer container: KeyedDecodingContainer<CruciblePersonalResult.CodingKeys>,
                          key: CruciblePersonalResult.CodingKeys,
                          out: T.Type) throws -> T where T: Decodable {
        let container = try container.nestedContainer(keyedBy: CruciblePersonalResult.CodingKeys.self,
                                                      forKey: key)
        let nestedBasicContainer = try container.nestedContainer(keyedBy: CruciblePersonalResult.CodingKeys.self,
                                                                 forKey: .basic)
        return try nestedBasicContainer.decode(out.self, forKey: .value)
    }
}

struct CruciblePersonalResult: Decodable {
    let period: String // Response.activities.period
    let activityDetails: ActivityDetails // Response.activities.activityDetails
    let assists: Int // Response.activities.values.assists.basic.value
    let score: Int
    let kills: Int
    let deaths: Int
    let efficiency: Double
    let killsDeathsRatio: Double
    let killsDeatheAssists: Double
    
    init(from decoder: Decoder) throws {
        let activities = try decoder.container(keyedBy: CodingKeys.self)
        
        self.period = try activities.decode(String.self, forKey: .period)
        self.activityDetails = try activities.decode(ActivityDetails.self, forKey: .activityDetails)
        
        let values = try activities.nestedContainer(keyedBy: CodingKeys.self,
                                                    forKey: .values)
        
        self.assists = try Values.decode(fromContainer: values, key: .assists, out: Int.self)
        self.score = try Values.decode(fromContainer: values, key: .score, out: Int.self)
        self.kills = try Values.decode(fromContainer: values, key: .kills, out: Int.self)
        self.deaths = try Values.decode(fromContainer: values, key: .deaths, out: Int.self)
        self.efficiency = try Values.decode(fromContainer: values, key: .efficiency, out: Double.self)
        self.killsDeathsRatio = try Values.decode(fromContainer: values, key: .killsDeathsRatio, out: Double.self)
        self.killsDeatheAssists = try Values.decode(fromContainer: values, key: .killsDeathsAssists, out: Double.self)
    }
}

extension CruciblePersonalResult: CustomStringConvertible {
    var description: String {
        return "Date: \(period), Score: \(score), Kills: \(kills), Deaths: \(deaths), Assists: \(assists)"
    }
}

extension CruciblePersonalResult {
    enum CodingKeys: String, CodingKey {
        case period
        case activityDetails
        case values
        case basic
        case value
        case assists
        case score
        case kills
        case deaths
        case efficiency
        case killsDeathsRatio
        case killsDeathsAssists
    }
}
