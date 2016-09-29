//
//  PlayerStatsTableViewController.swift
//  fantasy_bball_v1.2
//
//  Created by Kevin Ho on 2/26/16.
//  Copyright © 2016 DankApp. All rights reserved.
//
//
//  Notes: Displays player info, game logs, and news of selected player.
//

import UIKit
import RealmSwift


// Constants (public)
// Subject to update with start of each season

let CURRENT_SEASON  = "2015-16"
let CURRENT_YEAR    = "2016"
let NUM_STATS       = 13

class PlayerStatsTableViewController: UITableViewController {
    
    
    ///////////////////     Initialization & Constants    \\\\\\\\\\\\\\\\\\\\
    
    let currentGameLogs = realm.objects(GameLogs)
    var storedOffsets = [Int: CGFloat]()
    
    let nameRealm = realm.objects(PlayerSelected)

    func saveGameLog(gameVal: Int, idx: Int) {
        
        let name = nameRealm[0].playerName
        let player = realm.objects(NBAPlayer).filter("playerName = %@", name)
        let player_id = player[0].playerInfo?.playerID
        
        // http://stats.nba.com/stats/playergamelog/?playerid=977&season=2015-16&seasontype=Regular%20Season
        
        // Fill cells with appropriate stat for category
        // Store most recent game log into array (GAME LOG)
        
        // # of columns for stat line
        var gameLogStats = [String](count: NUM_STATS, repeatedValue: "0")
        var stat1, stat2, stat3, stat4, stat5, stat6, stat7, stat8, stat9, stat10, stat11, stat12, stat13 : String
        stat2 = ""
        stat3 = ""
        
        let endpoint = "playergamelog"
        let params = "PlayerID=" + player_id! + "&Season=" + CURRENT_SEASON + "&SeasonType=Regular%20Season"
        let gameLogArray = getRowSetArr(endpoint, para: params, setName: "PlayerGameLog", isRow: true)
        
        
        // Index out of bounds when gameVal => count, since those game logs dont exist if player hasn't played gameVal # games
        //  -> else = empty stat line
        if gameVal < gameLogArray.count {
        
            // OPP
            let temp_stat1 = String((gameLogArray[gameVal] as! NSArray)[4])
//            let temp_stat1 = String(gameLogArray[gameVal][4])
            var last2 = ""
            if temp_stat1.characters.contains("@") { last2 = "@" + temp_stat1.substringFromIndex(temp_stat1.endIndex.advancedBy(-3)) }
            else { last2 = temp_stat1.substringFromIndex(temp_stat1.endIndex.advancedBy(-3)) }
            stat2 = last2
            
            // FGM/A
            stat3 = String((gameLogArray[gameVal] as! NSArray)[7]) + "/" + String((gameLogArray[gameVal] as! NSArray)[8])
//            stat3 = String(gameLogArray[gameVal][7]) + "/" + String(gameLogArray[gameVal][8])
            
            // FG%
            let temp_stat4 = String((gameLogArray[gameVal] as! NSArray)[9])
//            let temp_stat4 = String(gameLogArray[gameVal][9])
            let fl_stat4 = (temp_stat4 as NSString).floatValue
            let roundedFG = Double(round(100*fl_stat4)/100)
            let formattedRoundedFG = NSString(format:"%.02f", roundedFG) as String
            stat4 = formattedRoundedFG
            
            // FTM/A
            stat5 = String((gameLogArray[gameVal] as! NSArray)[13]) + "/" + String((gameLogArray[gameVal] as! NSArray)[14])
//            stat5 = String(gameLogArray[gameVal][13]) + "/" + String(gameLogArray[gameVal][14])
            
            // FT%
            let temp_stat6 = String((gameLogArray[gameVal] as! NSArray)[15])
//            let temp_stat6 = String(gameLogArray[gameVal][15])
            let fl_stat6 = (temp_stat6 as NSString).floatValue
            let roundedFT = Double(round(100*fl_stat6)/100)
            let formattedRoundedFT = NSString(format:"%.02f", roundedFT) as String
            stat6 = formattedRoundedFT
            
            // 3PTM
            stat7 = String((gameLogArray[gameVal] as! NSArray)[10])
//            stat7 = String(gameLogArray[gameVal][10])
            
            // PTS
            stat8 = String((gameLogArray[gameVal] as! NSArray)[24])
//            stat8 = String(gameLogArray[gameVal][24])
            
            // REB
            stat9 = String((gameLogArray[gameVal] as! NSArray)[18])
//            stat9 = String(gameLogArray[gameVal][18])
            
            // AST
            stat10 = String((gameLogArray[gameVal] as! NSArray)[19])
//            stat10 = String(gameLogArray[gameVal][19])
            
            // STL
            stat11 = String((gameLogArray[gameVal] as! NSArray)[20])
//            stat11 = String(gameLogArray[gameVal][20])
            
            // BLK
            stat12 = String((gameLogArray[gameVal] as! NSArray)[21])
//            stat12 = String(gameLogArray[gameVal][21])
            
            // TO
            stat13 = String((gameLogArray[gameVal] as! NSArray)[22])
//            stat13 = String(gameLogArray[gameVal][22])
            
            // DATE (to be formatted)
            let date = String((gameLogArray[gameVal] as! NSArray)[3])
//            let date = String(gameLogArray[gameVal][3])
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            let formattedDate = dateFormatter.dateFromString(date)
            let calendar = NSCalendar.currentCalendar()
            let dateComponents = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month], fromDate: formattedDate!)

            stat1 = String(dateComponents.month) + "/" + String(dateComponents.day)
            
            
        } else {
            
            stat1 = ""
            stat2 = ""
            stat3 = ""
            stat4 = ""
            stat5 = ""
            stat6 = ""
            stat7 = ""
            stat8 = ""
            stat9 = ""
            stat10 = ""
            stat11 = ""
            stat12 = ""
            stat13 = ""
            
        }
        
        gameLogStats[0] = stat1
        gameLogStats[1] = stat2
        gameLogStats[2] = stat3
        gameLogStats[3] = stat4
        gameLogStats[4] = stat5
        gameLogStats[5] = stat6
        gameLogStats[6] = stat7
        gameLogStats[7] = stat8
        gameLogStats[8] = stat9
        gameLogStats[9] = stat10
        gameLogStats[10] = stat11
        gameLogStats[11] = stat12
        gameLogStats[12] = stat13
        
        var data2 : GameLogs
        data2 = currentGameLogs[0]
        
        let statistic = Stats()
        statistic.stat = gameLogStats[idx]
        
        if gameVal == 0 {
            try! realm.write {
                data2.log1[idx] = statistic
            }
        }
        
        if gameVal == 1 {
            try! realm.write {
                data2.log2[idx] = statistic
            }
        }
        
        if gameVal == 2 {
            try! realm.write {
                data2.log3[idx] = statistic
            }
        }
        
        if gameVal == 3 {
            try! realm.write {
                data2.log4[idx] = statistic
            }
        }
        
        if gameVal == 4 {
            try! realm.write {
                data2.log5[idx] = statistic
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black

        let screenSize: CGRect = UIScreen.mainScreen().bounds
        print(screenSize.size)
        
        var gameIndex = 0
        var statIndex = 0
        
        while gameIndex < 5
        {
            statIndex = 0
            while statIndex < NUM_STATS
            {
                saveGameLog(gameIndex, idx: statIndex)
                statIndex += 1
            }
            gameIndex += 1
        }
        
    }
    
    
    
    ///////////////////     Table View Data Source    \\\\\\\\\\\\\\\\\\\\

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Player Info"
        }
        else if section == 1 {
            return "Recent Games"
        }
        else {
            return "Recent News"
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        // Heights
        
        // 480:
        // iPad: 2, Air, Air 2
        // iPhone: 4S
        
        // 667:
        // iPad: Pro, Retina
        // iPhone: 6S
     
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        // iPhone 4, iPad 2/Air/Air2
        if screenSize.height == 480.0 {
            return 150
        } else {
            if indexPath.section == 2 {
                let sectionHeight = screenSize.height - 384 - 64    // 384 = previous sections + headers, 64 =  status + nav bar
                return sectionHeight
            } else {
                return 150
            }
     
        }
        
    }
 
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell : UITableViewCell!
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("infoCell", forIndexPath: indexPath)
        }
        
        else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier("statsCell", forIndexPath: indexPath)
        }
            
        else {
        // indexPath.section == 2
            cell = tableView.dequeueReusableCellWithIdentifier("newsCell", forIndexPath: indexPath)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        if indexPath.section != 0 {
            guard let tableViewCell = cell as? PlayerStatsTableViewCell else { return }
            tableViewCell.tag = indexPath.section
            tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.section)
            tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
        }
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        if indexPath.section != 0 {
            guard let tableViewCell = cell as? PlayerStatsTableViewCell else { return }
            tableViewCell.tag = indexPath.section
            storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
        }
    }

}




///////////////////     Collection View Data Source    \\\\\\\\\\\\\\\\\\\\

extension PlayerStatsTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // Scrap relevant data from Rotoworld -- subject to update
    func getNews() -> [[String]] {
    
        
        ///////////////////     Initialization    \\\\\\\\\\\\\\\\\\\\
        
        let selectedPlayer = realm.objects(PlayerSelected)
        let playerName = selectedPlayer[0].playerName
        let player = realm.objects(NBAPlayer).filter("playerName = %@", playerName)
        var newsArray = [[String]]()
        
        
        
        ///////////////////     Get News Data    \\\\\\\\\\\\\\\\\\\\
        
        // Scrap relevant data from Rotoworld -- subject to update
        //  ex: http://www.rotoworld.com/player/nba/1622/jeff-teague
        
        let rotoURLString = player[0].playerInfo?.rotoURLString
        if let rotoURL = NSURL(string: rotoURLString!) {
            do {
                
                let webContent = try String(contentsOfURL: rotoURL, encoding: NSUTF8StringEncoding)
                let endWebContent = webContent.componentsSeparatedByString("<div class=\"moreplayernews\"")
                
                let playerContent = endWebContent[0]
                
                let reportArray = playerContent.componentsSeparatedByString("<div class='report'>")
                
                // Gather recent reports
                if reportArray.count > 1 {
                    
                    for n in 2 ..< reportArray.count {
                        
                        // Gather initial report (part 1) = 'report' section
                        let reportData = reportArray[n].componentsSeparatedByString("</div>")
                        let report = reportData[0]
                        
                        // Gather secondary report (part 2) = 'impact' section
                        let impactArray = reportArray[n].componentsSeparatedByString("<div class='impact'>")
                        let impactData = impactArray[1]
                        
                        let dateArray = impactData.componentsSeparatedByString(" <span class='date'>")
                        let impact = dateArray[0]
                        let dateData = dateArray[1]
                        
                        // Gather date of reports
                        let dateData2 = dateData.componentsSeparatedByString("</span>")
                        let date = dateData2[0]
                        
                        newsArray.append([date, report, impact])
                    }
                    
                }
                
            } catch {
                print("Error : \(error)")
            }
            
        } else {
            //print("Error: \(rotoURLString) doesn't  URL")
        }
        
        return newsArray
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == 1 {
            return NUM_STATS   // Stat columns
        }
        
        else {
            return 4    // News reports
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 1 {
            
            let statLabels = [" ", "OPP", "FG", "FG%", "FT", "FT%", "3PM", "PTS", "REB", "AST", "STL", "BLK", "TO"]

            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("statsCell2", forIndexPath: indexPath) as! PlayerStatsCollectionViewCell

            cell.cellLabel.text = statLabels[indexPath.row]
            cell.statVal1.text = currentGameLogs[0].log1[indexPath.row].stat
            cell.statVal2.text = currentGameLogs[0].log2[indexPath.row].stat
            cell.statVal3.text = currentGameLogs[0].log3[indexPath.row].stat
            cell.statVal4.text = currentGameLogs[0].log4[indexPath.row].stat
            cell.statVal5.text = currentGameLogs[0].log5[indexPath.row].stat

            return cell
        
        } else {
        
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("newsCell2", forIndexPath: indexPath) as! PlayerNewsCollectionViewCell
            
            let playerNews = getNews()
            if playerNews.isEmpty {
                if indexPath.row == 0 {
                    cell.headline.text = "No recent news"
                    collectionView.scrollEnabled = false
                    return cell
                }
            } else {
                cell.date.text = playerNews[indexPath.row][0].stringByReplacingOccurrencesOfString(" - ", withString: ", ")
                cell.report.text = playerNews[indexPath.row][1].stringByReplacingOccurrencesOfString("&quot;", withString: "\"")
                cell.impact.text = playerNews[indexPath.row][2].stringByReplacingOccurrencesOfString("&quot;", withString: "\"")
            }

            return cell
        
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Collection view at section \(collectionView.tag) selected index path \(indexPath)")
    }
}

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}


