//
//  SeasonStats.swift
//  Hockey Info
//
//  Created by Larry Burris on 12/3/18.
//  Copyright © 2018 Larry Burris. All rights reserved.
//

// To parse the JSON, add this file to your project and do:
//
//   let seasonTeamStats = try? newJSONDecoder().decode(SeasonTeamStats.self, from: jsonData)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseSeasonTeamStats { response in
//     if let seasonTeamStats = response.result.value {
//       ...
//     }
//   }
import Foundation
import RealmSwift
import SwifterSwift
import Alamofire
import Kingfisher
import SVProgressHUD

class SeasonStats
{
    let today = Date()
    
    let shortDateFormatter = DateFormatter()
    
    func getStats()
    {
        //  Set the URL
        let url = URL(string: "https://api.mysportsfeeds.com/v2.0/pull/nhl/2018-2019-regular/standings.json")
        let session = URLSession.shared
        var request = URLRequest(url: url!)
        
        request.addValue("Basic " + "lburris57:MYSPORTSFEEDS".toBase64()!, forHTTPHeaderField: "Authorization")
        
        //  Get the JSON data with closure
        session.dataTask(with: request)
        {
            (data, response, err) in
            
            if err == nil
            {
                do
                {
                    //let jsonString = String(data: Data(data!), encoding: .utf8)
                    
                    //print("JSON string is: \(jsonString ?? "")")
                    
                    //print(response)
                    
                    let seasonTeamStats = try JSONDecoder().decode(SeasonTeamStats.self, from: data!)
                        
                    //print("Value of seasonTeamStats is \(seasonTeamStats)")
                    
                    for teamStatReference in seasonTeamStats.references.teamStatReferences
                    {
                        print("-----------------------------------------")
                        print("Category is \(teamStatReference.category)")
                        print("Type is \(teamStatReference.type)")
                        print("Description is \(teamStatReference.description)")
                        print("Abbreviation is \(teamStatReference.abbreviation)")
                        print("Full Name is \(teamStatReference.fullName)")
                    }
                }
                catch
                {
                    print("Error retrieving data...\(err.debugDescription)")
                }
            }
        }.resume()
    }
    
    
    
    
    
    
    
    
    func retrieveSeasonStats(_ viewController: MainTableViewController)
    {
        print("In retrieveSeasonStats method...")
        
        shortDateFormatter.dateFormat = "yyyyMMdd"
        /*
        //  Set the URL string
        var myUrl = "https://api.mysportsfeeds.com/v2.0/pull/nhl/2018-2019-regular/standings.json"
        
        myUrl = myUrl.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        
        let url = URL(string: myUrl)
        
        //  Get the JSON data with closure
        URLSession.shared.dataTask(with: url!)
        {
            (data, response, err) in
            
            //  Perform decoding if no errors
            if err == nil
            {
                do
                {
                    //  Decode the JSON file into a PlayerInfo object
                    let seasonTeamStats = try JSONDecoder().decode(SeasonTeamStats.self, from: data!)
                    
                    let lastUpdatedOn = seasonTeamStats.lastUpdatedOn
                    
                    print("Value of lastUpdatedOn in SeasonStats.retrieveScores is \(lastUpdatedOn)")
                }
                catch
                {
                    print("Error decoding JSON")
                }
            }*/
        
        Alamofire.request("https://api.mysportsfeeds.com/v2.0/pull/nhl/2018-2019-regular/standings.json",
                          headers: ["Authorization" : "Basic " + "lburris57:MYSPORTSFEEDS".toBase64()!]).responseJSON{ response in

            if let jsonData = response.data
            {
                //print("JSON data is: \(jsonData)")
                
                //let jsonString = String(data: Data(jsonData), encoding: .utf8)
                
                //print("JSON string is: \(jsonString ?? "")")
                
                let nhlStandings = try? newJSONDecoder().decode(NHLStandings.self, from: jsonData)
                
                print(nhlStandings ?? "Something fucked up here.....")

                let lastUpdatedOn = nhlStandings?.lastUpdatedOn

                print("Value of lastUpdatedOn in SeasonStats.retrieveScores is \(lastUpdatedOn ?? "WTF is going on here??")")
        
            }
            else
            {
                print("Error is \(response.error.debugDescription)")
            }
        }
        
            print("Leaving retrieveSeasonStats method...")
            
    }//.resume()
    
}

struct SeasonTeamStats: Codable {
    let lastUpdatedOn: String
    //let teamStatsTotals: [TeamStatsTotal]
    let references: References
}

struct References: Codable {
    let teamStatReferences: [TeamStatReference]
}

struct TeamStatReference: Codable {
    let category: Category
    let fullName, description, abbreviation: String
    let type: TypeEnum
}

enum Category: String, Codable {
    case faceoffs = "Faceoffs"
    case miscellaneous = "Miscellaneous"
    case powerplay = "Powerplay"
    case standings = "Standings"
}

enum TypeEnum: String, Codable {
    case decimal = "DECIMAL"
    case integer = "INTEGER"
}

struct TeamStatsTotal: Codable {
    let team: Team
    let stats: Stats
}

struct Stats: Codable {
    let gamesPlayed: Int
    let standings: Standings
    let faceoffs: Faceoffs
    let powerplay: Powerplay
    let miscellaneous: Miscellaneous
}

struct Faceoffs: Codable {
    let faceoffWINS, faceoffLosses: Int
    let faceoffPercent: Double
    
    enum CodingKeys: String, CodingKey {
        case faceoffWINS = "faceoffWins"
        case faceoffLosses, faceoffPercent
    }
}

struct Miscellaneous: Codable {
    let goalsFor, goalsAgainst, shots, penalties: Int
    let penaltyMinutes, hits: Int
}

struct Powerplay: Codable {
    let powerplays, powerplayGoals: Int
    let powerplayPercent: Double
    let penaltyKills, penaltyKillGoalsAllowed: Int
    let penaltyKillPercent: Double
}

struct Standings: Codable {
    let wins, losses, overtimeWINS, overtimeLosses: Int
    let points: Int
    
    enum CodingKeys: String, CodingKey {
        case wins, losses
        case overtimeWINS = "overtimeWins"
        case overtimeLosses, points
    }
}

struct Team: Codable {
    let id: Int
    let city, name, abbreviation: String
    let homeVenue: HomeVenue
    let teamColoursHex, socialMediaAccounts: [JSONAny]
    let officialLogoImageSrc: JSONNull?
}

struct HomeVenue: Codable {
    let id: Int
    let name: String
}

// MARK: Encode/decode helpers

class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public var hashValue: Int {
        return 0
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

class JSONCodingKey: CodingKey {
    let key: String
    
    required init?(intValue: Int) {
        return nil
    }
    
    required init?(stringValue: String) {
        key = stringValue
    }
    
    var intValue: Int? {
        return nil
    }
    
    var stringValue: String {
        return key
    }
}

class JSONAny: Codable {
    let value: Any
    
    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }
    
    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }
    
    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }
    
    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }
    
    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }
    
    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }
    
    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }
    
    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }
    
    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }
    
    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }
    
    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            self.value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            self.value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self.value = try JSONAny.decode(from: container)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: self.value)
        }
    }
}

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// MARK: - Alamofire response handlers

extension DataRequest {
    fileprivate func decodableResponseSerializer<T: Decodable>() -> DataResponseSerializer<T> {
        return DataResponseSerializer { _, response, data, error in
            guard error == nil else { return .failure(error!) }
            
            guard let data = data else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
            }
            
            return Result { try newJSONDecoder().decode(T.self, from: data) }
        }
    }
    
    @discardableResult
    fileprivate func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: decodableResponseSerializer(), completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseSeasonTeamStats(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<SeasonTeamStats>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
}
