//
//  OverallRankData.swift
//  Hockey Info
//
//  Created by Larry Burris on 12/1/18.
//  Copyright © 2018 Larry Burris. All rights reserved.
//
import Foundation

struct OverallRankData: Decodable
{
    var rank: Int = 0
    var gamesBack: Double = 0.0
    
    private enum CodingKeys : String, CodingKey
    {
        case rank = "rank"
        case gamesBack = "gamesBack"
    }
}
