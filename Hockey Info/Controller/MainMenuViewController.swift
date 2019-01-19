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
    
    var alert: UIAlertController?
    
    let displayScoresViewController = DisplayScoresViewController()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if(databaseManager.teamRosterRequiresSaving())
        {
            self.presentInitialAlert()
            
            networkManager.saveRosters()
        }
        
        if(databaseManager.scheduleRequiresSaving())
        {
            networkManager.saveSchedule()
        }
        
        if(databaseManager.teamStandingsRequiresSaving())
        {
            networkManager.saveStandings()
        }
        
        if(databaseManager.gameLogRequiresSaving())
        {
            networkManager.saveGameLogs()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2)
            {
                self.dismissAlert()
            }
        }
        
        if(databaseManager.mainMenuCategoriesRequiresSaving())
        {
            databaseManager.saveMainMenuCategories()
        }
        
        categories = databaseManager.retrieveMainMenuCategories()
        
        //  If the player injury table is populated and the last updated date is not today,
        //  delete the current data and reload the table
        databaseManager.reloadInjuryTableIfRequired()
        
        if (databaseManager.tablesRequireReload())
        {
            //reloadTables()
        }
        else
        {
            //print("Tables don't need to be reloaded...")
        }
    }
    
    private func reloadTables()
    {
//        print("Reloading tables...")
//
//        self.presentUpdatingTablesAlert()
//
//        networkManager.reloadRosters()
//        networkManager.reloadSchedule()
//        networkManager.reloadStandings()
//        networkManager.reloadTeamStats()
//        networkManager.reloadPlayerStats()
//        networkManager.reloadGameLogs()
//        networkManager.reloadInjuries()
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2)
//        {
//            self.dismissAlert()
//        }
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
        if (databaseManager.tablesRequireReload())
        {
            //reloadTables()
        }
        
        if(databaseManager.teamTableRequiresLinking())
        {
            linkTables()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let category = categories[indexPath.row].category

        if(category == "Scores")
        {
            networkManager.updateScheduleForDate(Date())
            
            databaseManager.displaySchedule(self, "displayScores")
        }
        else if(category == "Season Schedule")
        {
            databaseManager.retrieveTodaysGames(self)
        }
        else if(category == "Team Information")
        {
            databaseManager.displayTeams(self, category)
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
        else if(segue.identifier == "displayAllTeams")
        {
            let displayTeamsViewController = segue.destination as! DisplayTeamsViewController
            
            displayTeamsViewController.segueId = segue.identifier!
            
            displayTeamsViewController.teamResults = sender as? Results<NHLTeam>
        }
        else if(segue.identifier == "displayScores")
        {
            let displayScoresViewController = segue.destination as! DisplayScoresViewController
            
            displayScoresViewController.nhlSchedules = sender as? Results<NHLSchedule>
        }
        else if(segue.identifier == "displayStandings")
        {
            let displayStandingsTabViewController = segue.destination as! DisplayStandingsTabViewController
            
            displayStandingsTabViewController.teamStandingsResults = sender as? Results<TeamStandings>
        }
    }
}

extension MainMenuViewController
{
    func presentInitialAlert()
    {
        alert = UIAlertController(title: "Loading Database Tables", message: "Database tables must be populated the first time Hockey Info is run.  Please wait...", preferredStyle: .alert)
        alert!.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10,y: 5,width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert!.view.addSubview(loadingIndicator)
        self.present(alert!, animated: true)
    }
    
    func presentUpdatingTablesAlert()
    {
        alert = UIAlertController(title: "Loading Database Tables", message: "Database tables must be updated daily.  Please wait...", preferredStyle: .alert)
        alert!.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10,y: 5,width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert!.view.addSubview(loadingIndicator)
        self.present(alert!, animated: true)
    }
    
    func linkTables()
    {
        print("Linking table data...")
        
        //  If tables have been reloaded, remove existing
        //  team links to prevent duplicate data
        databaseManager.deleteTeamLinks()

        databaseManager.linkPlayersToTeams()
        databaseManager.linkStandingsToTeams()
        databaseManager.linkStatisticsToTeams()
        databaseManager.linkSchedulesToTeams()
        databaseManager.linkGameLogsToTeams()
        databaseManager.linkPlayerInjuriesToTeams()

        print("Linking of table data was successful!")

        networkManager.updateScheduleForDate(Date())
    }
    
    func dismissAlert()
    {
        self.alert?.dismiss(animated: false, completion: nil)
    }
}
