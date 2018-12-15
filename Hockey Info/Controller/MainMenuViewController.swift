//
//  MainMenuViewController.swift
//  Hockey Info
//
//  Created by Larry Burris on 12/2/18.
//  Copyright © 2018 Larry Burris. All rights reserved.
//
import UIKit
import RealmSwift

class MainMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    var categories = [MenuCategory]()
    
    let networkManager = NetworkManager()
    
    let databaseManager = DatabaseManager()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if(databaseManager.mainMenuCategoriesRequiresSaving())
        {
            databaseManager.saveMainMenuCategories()
        }
        
        if(databaseManager.teamStandingsRequiresSaving())
        {
            networkManager.saveStandings()
        }
        
        if(databaseManager.teamRosterRequiresSaving())
        {
            networkManager.saveRosters()
        }
        
        if(databaseManager.scheduleRequiresSaving())
        {
            networkManager.saveSchedule()
        }
        
        categories = databaseManager.retrieveMainMenuCategories()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if cell == nil
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        cell?.textLabel?.text = categories[indexPath.row].category
        
        cell?.accessoryType = .disclosureIndicator
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let category = categories[indexPath.row].category

        if(category == "Scores")
        {
            //networkManager.retrieveScores(self)
        }
        else if(category == "Schedule")
        {
            databaseManager.retrieveTodaysGames(self)
        }
        else if(category == "Team Rosters")
        {
            databaseManager.displayTeams(self)
        }
        else if(category == "Standings")
        {
            databaseManager.displayStandings(self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == "displaySchedule")
        {
            let displayCalendarViewController = segue.destination as! DisplayCalendarViewController

            displayCalendarViewController.scheduledGames = sender as? Results<NHLSchedule>
        }
        else if(segue.identifier == "displayTeams")
        {
            let displayTeamsViewController = segue.destination as! DisplayTeamsViewController
            
            displayTeamsViewController.teamResults = sender as? Results<NHLTeam>
        }
        else if(segue.identifier == "displayStandings")
        {
            let displayStandingsTabViewController = segue.destination as! DisplayStandingsTabViewController
            
            displayStandingsTabViewController.teamStandingsResults = sender as? Results<TeamStandings>
        }
        
    }
}