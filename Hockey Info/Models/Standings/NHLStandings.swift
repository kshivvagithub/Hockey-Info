//
//  NHLStandings.swift
//  Hockey Info
//
//  Created by Larry Burris on 12/1/18.
//  Copyright © 2018 Larry Burris. All rights reserved.
//
import Foundation

struct NHLStandings: Decodable
{
    var lastUpdatedOn: String
    var references: StandingsReferenceData
    var teamList: [TeamStandingsData]
    
    private enum CodingKeys : String, CodingKey
    {
        case lastUpdatedOn = "lastUpdatedOn"
        case references = "references"
        case teamList = "teams"
    }
}
