//
//  PlayerListTableViewController.swift
//  FantasyBuddy
//
//  Created by Kevin Ho on 2/25/16.
//  Copyright © 2016 Kevin Ho. All rights reserved.
//
//
//  Notes: Loads list of NBA players, detailed by position and team. Search implemented.
//

import UIKit
import RealmSwift

let realm = try! Realm()

class PlayerListTableViewController: UITableViewController {

    
    ///////////////////     Initialization & Constants    \\\\\\\\\\\\\\\\\\\\
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var playerRealm = realm.objects(NBAPlayer)
    var filteredPlayerRealm = realm.objects(NBAPlayer)
    var playerClicked = realm.objects(PlayerSelected)
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        tableView.setContentOffset(CGPoint(x: 0, y: searchController.searchBar.frame.size.height), animated: true)
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Memory warning")

        // Dispose of any resources that can be recreated.
    }

    
    

    ///////////////////     Table View Data Source    \\\\\\\\\\\\\\\\\\\\

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // # rows = # players in NBA
        
        if searchController.active && searchController.searchBar.text != "" {
            return filteredPlayerRealm.count
        }
        
        return playerRealm.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Populate each cell/row with NBA player from stored data in Realm
        
        let cell = tableView.dequeueReusableCellWithIdentifier("playerCell", forIndexPath: indexPath)
        
        var data : NBAPlayer
        if searchController.active && searchController.searchBar.text != "" {
            data = filteredPlayerRealm[indexPath.row]
        } else {
            data = playerRealm[indexPath.row]
        }
        
        let playerName = data.playerName
        var playerSub = String()
        let playerPos = data.playerInfo?.position
        let playerTeam = data.teamInfo?.abbreviation
        
        playerSub = playerTeam! + ", " + playerPos!
        
        cell.textLabel?.text = playerName
        cell.detailTextLabel?.text = playerSub

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Implement 'Loading' activity indicator after player is selected
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .White)
        cell!.accessoryView = activityIndicatorView
        activityIndicatorView.startAnimating()

        
        // Delay allows activity indicator to display fully
        delay(0.1) {
            
            // New player selected, clear game logs
            let currentGameLogs = realm.objects(GameLogs)
            for i in 0 ..< NUM_STATS {
                
                try! realm.write {
                    currentGameLogs[0].log1[i].stat = "nil"
                    currentGameLogs[0].log2[i].stat = "nil"
                    currentGameLogs[0].log3[i].stat = "nil"
                    currentGameLogs[0].log4[i].stat = "nil"
                    currentGameLogs[0].log5[i].stat = "nil"

                }
                
            }

            // Name of player, ie. "Kobe Bryant"
            let selectedPlayer = String(UTF8String: (tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text)!)!
            
            // Store name to database, will use in new view controller to display stats/game logs
            var data : PlayerSelected
            data = self.playerClicked[0]
            
            try! realm.write {
                data.playerName = selectedPlayer
            }
            
            activityIndicatorView.stopAnimating()

            // Initialize next view controller (view stats) after player selected
            let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let destination = storyboard.instantiateViewControllerWithIdentifier("PlayerStatsTableViewController") as! PlayerStatsTableViewController
            self.navigationController?.pushViewController(destination, animated: true)
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }

    }

    func filterContentForSearchText(searchText: String) {
        
        var text = String()
        text = searchText.lowercaseString
        filteredPlayerRealm = playerRealm.filter("playerName CONTAINS[c] %@", text)
        tableView.reloadData()

    }

}

extension PlayerListTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
