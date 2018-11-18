//
//  ViewController.swift
//  Hockey Info
//
//  Created by Larry Burris on 11/14/18.
//  Copyright © 2018 Larry Burris. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet var scoreView: UITableView!
    
    let today = Date()
    
    let shortDateFormatter = DateFormatter()
    let fullDateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    var timesRemaining = ["12:42", "09:47"]
    var visitingTeamNames = ["BLUE JACKETS", "OILERS"]
    var visitingTeamRecords = ["44-17-10", "47-14-10"]
    var homeTeamNames = ["CAPITALS", "FLAMES"]
    var homeTeamRecords = ["47-14-10", "44-17-10"]
    var visitingTeamScores = ["2", "1"]
    var homeTeamScores = ["5", "2"]
    var periods = ["3rd", "2nd"]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        fullDateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        timeFormatter.dateFormat = "hh:mm a"
        shortDateFormatter.dateFormat = "yyyyMMdd"
        
        scoreView.dataSource = self
        scoreView.delegate = self
        
        let nib = UINib(nibName: "ScoreCell", bundle: nil)
        scoreView.register(nib, forCellReuseIdentifier: "scoreCell")
        
        downloadGameData()
    }
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    // MARK: - Scores Table Header Code
    
    /// Creates the header title for the scores table view
    ///
    /// - Parameters:
    ///   - tableView: scores table view
    ///   - section: the section header
    /// - Returns: String representation of the section header text
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "Scores for " + fullDateFormatter.string(from: today) + " at " + timeFormatter.string(from: today)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        header.textLabel?.adjustsFontSizeToFitWidth = true
        
        view.tintColor = UIColor.black
    }

    // MARK: - Scores Table Cell Code
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return timesRemaining.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scoreCell") as! ScoreCell
        
        scoreView.rowHeight = CGFloat(130.0)
        
        cell.timeRemaining.text = timesRemaining[indexPath.row] + " remaining"
        cell.visitingTeamName.text = visitingTeamNames[indexPath.row]
        cell.visitingTeamRecord.text = visitingTeamRecords[indexPath.row]
        cell.homeTeamName.text = homeTeamNames[indexPath.row]
        cell.homeTeamRecord.text = homeTeamRecords[indexPath.row]
        cell.visitingTeamScore.text = visitingTeamScores[indexPath.row]
        cell.homeTeamScore.text = homeTeamScores[indexPath.row]
        cell.period.text = periods[indexPath.row]
        
        return cell
    }
    
    // MARK: - Network code
    func downloadGameData()
    {
        print("https://api.mysportsfeeds.com/v2.0/pull/nhl/2018-2019-regular/date/" + shortDateFormatter.string(from: today) + "/games.json")
        //https://api.mysportsfeeds.com/v2.0/pull/nhl/2018-2019-regular/date/20181021/games.json
        
        Alamofire.request(
            "https://api.mysportsfeeds.com/v2.0/pull/nhl/2018-2019-regular/date/" + shortDateFormatter.string(from: today) + "/games.json",
            headers: ["Authorization" : "Basic " + "lburris57:MYSPORTSFEEDS".toBase64()!]
            )
            .responseJSON
            { (response) in
                
                switch response.result
                {
                    case .success:
                        
                        let json = JSON(response.result.value!)
                        
                        print("Original JSON is:\n \(json)")
                        
                        let lastUpdatedOn = json["lastUpdatedOn"].stringValue
                        
                        //print("Response is:\n\(response)")
                        
                        //print("Value of json is: \(json)")
                        
                        print("Value of lastUpdatedOn is: \(lastUpdatedOn)")
                    
                        //guard let jsonData = response.value else {print("Error retrieving json data"); return}
                        //print("jsonData: \(jsonData)")
                    
                        /*do{
                         //let scoreboard = try JSONDecoder().decode(Scoreboard.self, from: jsonData)
                         //print("Last updated date: \(scoreboard.lastUpdatedOn)")
                         print("Last updated date: ")
                     
                         }catch {
                         //print("Error: \(error)")
                         }*/
                    
                    case .failure(let error):
                        print(error)
                    
                }
                //                    guard response.result.isSuccess else
                //                    {
                //                        print("Error while fetching data: \(response.result.error!)")
                //                        return
                //                    }
                //
                //                    guard let responseJSON = response.result.value as? [String: Any] else
                //                    {
                //                        print("Invalid JSON information received from the service")
                //                        return
                //                    }
                //
                //                    do
                //                    {
                //                        //  Decode the JSON file into a TeamInfo object
                //                        let scoreboard = try JSONDecoder().decode(Scoreboard.self, from: data)
                //                    }
                //                    catch
                //                    {
                //                        print("Error decoding JSON")
                //                    }
        }
    }
}

extension String
{
    func fromBase64() -> String?
    {
        guard let data = Data(base64Encoded: self, options: Data.Base64DecodingOptions(rawValue: 0)) else
        {
            return nil
        }
        
        return String(data: data as Data, encoding: String.Encoding.utf8)
    }
    
    func toBase64() -> String?
    {
        guard let data = self.data(using: String.Encoding.utf8) else
        {
            return nil
        }
        
        return data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }
}
