//
//  AppDelegate.swift
//  FantasyBuddy
//
//  Created by Kevin Ho on 2/25/16.
//  Copyright © 2016 Kevin Ho. All rights reserved.
//

import UIKit
import RealmSwift



///////////////////     BEGIN - INIT / CLASSES    \\\\\\\\\\\\\\\\\\\\


class PlayerSummary: Object {
    
    dynamic var name            = ""
    dynamic var number          = ""
    dynamic var position        = ""
    dynamic var playerID        = ""
    dynamic var teamID          = ""
    dynamic var rotoURLString   = ""
    dynamic var injured         = false
    
}

class TeamSummary: Object {
    
    dynamic var city            = ""
    dynamic var name            = ""
    dynamic var teamName        = ""
    dynamic var abbreviation    = ""
    dynamic var teamID          = ""
    
}

class NBAPlayer: Object {
    
    dynamic var playerName = ""
    dynamic var playerInfo: PlayerSummary?
    dynamic var teamInfo: TeamSummary?
    
}

class NBAPlayerList: Object {
    
    var players = List<NBAPlayer>()
}

class PlayerSelected: Object {

    dynamic var playerName = ""

}

class Stats: Object {
    dynamic var stat = ""
}


class GameLogs: Object {

    let log1 = List<Stats>()
    let log2 = List<Stats>()
    let log3 = List<Stats>()
    let log4 = List<Stats>()
    let log5 = List<Stats>()

}

class Items: Object {

    dynamic var item = ""
    
}

class Matchup: Object {

    dynamic var date = ""
    dynamic var time = ""
    dynamic var homeTeam = ""
    dynamic var awayTeam = ""

}


// DESCRIPTION:
// Gets relevant branch ("resultSets") from JSON data stored at designated URL

func getRowSetArr(endpoint: String, para: String, setName: String, isRow: Bool) -> NSArray {
    
    var rowSetArr = NSArray()
    
    let parameters = para
    let urlString = "http://stats.nba.com/stats/" + endpoint + "/?" + parameters
    let url = NSURL(string: urlString)
    let data: NSData? = NSData(contentsOfURL: url!)
    
    do
    {
        if let jsonResult: NSDictionary =
            try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
        {
            let rsArray = jsonResult["resultSets"] as! NSArray
            
            if !isRow { return rsArray }
            
            let resultSets = rsArray[0] as! NSDictionary
            let rsName = resultSets["name"] as! String
            
            if rsName == setName
            {
                // Holds rowSet array
                rowSetArr = resultSets["rowSet"] as! NSArray
            }
        }
    } catch let error as NSError {
        print("Error:\n \(error)")
    }
    
    return rowSetArr
}



///////////////////     END - INIT / CLASSES    \\\\\\\\\\\\\\\\\\\\







@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let NUM_STATS = 13

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        // Override point for customization after application launch.
        
        
        
        ////////////////////     Initialization & Constants     \\\\\\\\\\\\\\\\\\\\
        
        // Initialize empty Realm
        let realm = try! Realm()
        let testRealm = realm.isEmpty
        if (!testRealm) {
            try! realm.write {
            realm.deleteAll()
            }
        }

        // Constants
        let PREV_SEASON             = "2015-16"
        let CURRENT_SEASON          = "2016-17"
        let CURRENT_YEAR            = "2016"
        
        let f_team_id               = "1610612737"
        let l_team_id               = "1610612766"
        let first_team_id           = Int(f_team_id)
        let last_team_id            = Int(l_team_id)
        
        
        // Global Arrays
        var playerIDArray           = [String]()
        var playerNameArray         = [String]()
        var injuredPlayers          = [String]()

        var playerDictionary        = [String: AnyObject]()
        var playerInfoDict          = [String:[Dictionary<String,String>]]()
        var teamInfoDict            = [String:[Dictionary<String,String>]]()
        var rotoDict                = [String:String]()
        
        
        // DESCRIPTION:
        // paramsArray holds the URL parameters for each team in the current season
        
        func getParams(season: String, end_para: String) -> [String] {
            
            var paramsArray      = [String]()
            var current_team_id  = first_team_id!
            
            while current_team_id <= last_team_id
            {
                let team_id = String(current_team_id)
                let parameters = "Season=" + season + "&TeamID=" + team_id + end_para
                paramsArray.append(parameters)
                current_team_id += 1;
            }
            
            return paramsArray
        }
    
        
        
        
        ////////////////////     Dictionaries - Player & Team Info     \\\\\\\\\\\\\\\\\\\\

        do {
            
            // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\
            
            //  Player Info
            
            // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\
            
            // Ex: http://stats.nba.com/stats/commonteamroster/?season=2015-16&teamid=1610612737

            // DESCRIPTION:
            // Parse through JSON data stored for each player at player-specific URL
            // Store relevant data to specific dictionary
            // Return player dictionary
            
            func getPlayerInfo() -> [String:[Dictionary<String,String>]]
            {
                var playerInfoDict = [String:[Dictionary<String,String>]]()
                
                // Endpoint
                let endpoint = "commonteamroster"
                
                // Parameters
                let paramsArray = getParams(CURRENT_SEASON, end_para: "")
                
                for i in 0 ..< paramsArray.count
                {
                
                    let rsArray = getRowSetArr(endpoint, para: paramsArray[i], setName: "CommonTeamRoster", isRow: false)
                    for resultSets in rsArray
                    {
                        let rsName = resultSets["name"] as! String
                        if rsName == "CommonTeamRoster" {
                            let headersArray = resultSets["headers"] as! NSArray
                            let rowSetArray = resultSets["rowSet"] as! NSArray
                            for j in 0 ..< rowSetArray.count {

                                // { "Player Info": [] } (Array of Dictionaries)
                                var playerInfoArray = [Dictionary<String,String>]()
                                
                                // PLAYER_NAME (Dictionary)
                                let playerName = (headersArray[3] as! String) + "_NAME"
                                let currentPlayerName = String((rowSetArray[j] as! NSArray)[3])
//                              let currentPlayerName = String(rowSetArray[j][3])
                                let playerNameDict: [String:String] =
                                [
                                    playerName : currentPlayerName
                                ]
                                playerInfoArray.append(playerNameDict)
                                playerNameArray.append(currentPlayerName)
                                
                                
                                // NUM (Dictionary)
                                let playerNum = (headersArray[4] as! String)
                                let playerNumDict: [String:String] =
                                [
                                    playerNum : String((rowSetArray[j] as! NSArray)[4])
//                                  playerNum : String(rowSetArray[j][4])
                                ]
                                playerInfoArray.append(playerNumDict)
                                
                                // POSITION (Dictionary)
                                let playerPos = (headersArray[5] as! String)
                                let playerPosDict: [String:String] =
                                [
                                    playerPos : String((rowSetArray[j] as! NSArray)[5])
//                                  playerPos : String(rowSetArray[j][5])
                                ]
                                playerInfoArray.append(playerPosDict)
                                
                                
                                // PLAYER_ID (Dictionary)
                                let playerID = (headersArray[12] as! String)
                                let currentPlayerID = String((rowSetArray[j] as! NSArray)[12])
//                              let currentPlayerID = String(rowSetArray[j][12])
                                let playerIDDict: [String:String] =
                                [
                                    playerID : currentPlayerID
                                ]
                                playerInfoArray.append(playerIDDict)
                                playerIDArray.append(currentPlayerID)
                                
                                
                                // TEAM_ID
                                var isTeamID = (headersArray[0] as! String)
                                if isTeamID == "TeamID" { isTeamID = "TEAM_ID" }
                                let teamIDDict: [String:String] =
                                [
                                    isTeamID : String((rowSetArray[j] as! NSArray)[0])
//                                  isTeamID : String(rowSetArray[j][0])
                                ]
                                playerInfoArray.append(teamIDDict)
                                
                                
                                // Add all player info to "Player Info" array
                                playerInfoDict[currentPlayerName] = playerInfoArray
                                
                            }
                        }
                    }
                    
                }
    
                return playerInfoDict
            }
            
            playerInfoDict = getPlayerInfo()
            
            
            
            
            // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\
            
            //  Team Info
            
            // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \\

            // Ex: http://stats.nba.com/stats/teaminfocommon/?Season=2015-16&TeamID=1610612737&LeagueID=00&SeasonType=Regular%20Season
            
            // DESCRIPTION:
            // Parse through JSON data stored for each team at team-specific URL
            // Store relevant data to specific dictionary
            // Return team dictionary
            
            func getTeamInfo() -> [String:[Dictionary<String,String>]]
            {
                var teamInfoDict = [String:[Dictionary<String,String>]]()
                
                // Endpoint
                let endpoint = "teaminfocommon"
                
                // Parameters
                let paramsArray = getParams(CURRENT_SEASON, end_para: "&LeagueID=00&SeasonType=Regular%20Season")
                
                for i in 0 ..< paramsArray.count
                {
                    
                    let rsArray = getRowSetArr(endpoint, para: paramsArray[i], setName: "TeamInfoCommon", isRow: false)
                    
                    for resultSets in rsArray
                    {
                        let rsName = resultSets["name"]
                        if rsName as! String == "TeamInfoCommon" {
                            let headersArray = resultSets["headers"] as! NSArray
                            let rowSetArray = resultSets["rowSet"] as! NSArray
                            
                            
                            // { "Team Info": [] } (Array of Dictionaries)
                            var teamInfoArray = [Dictionary<String,String>]()
                            
                            // TEAM_CITY (Dictionary)
                            let teamCity = (headersArray[2] as! String)
                            let teamCityDict: [String:String] =
                            [
                                teamCity : String((rowSetArray[0] as! NSArray)[2])
//                              teamCity : String(rowSetArray[0][2])
                            ]
                            teamInfoArray.append(teamCityDict)
                            
                            
                            // TEAM_NAME (Dictionary)
                            let teamName = (headersArray[3] as! String)
                            let rawTeamName = String((rowSetArray[0] as! NSArray)[3])
//                          let rawTeamName = String(rowSetArray[0][3])
                            var formattedTeamName = rawTeamName
                            if rawTeamName == "Trail Blazers" { formattedTeamName = "Trailblazers" }
                            //let formattedTeamName = rawTeamName.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                            let teamNameDict: [String:String] =
                            [
                                teamName : formattedTeamName
                            ]
                            teamInfoArray.append(teamNameDict)
                            
                            
                            // TEAM_NAME (full) (Dictionary)
                            let teamNameFull = "TEAM_NAME_FULL"
                            let teamString = String((rowSetArray[0] as! NSArray)[2]) + " " + formattedTeamName
//                            let teamString = String(rowSetArray[0][2]) + " " + formattedTeamName
                            let teamNameFullDict: [String:String] =
                            [
                                teamNameFull : teamString
                            ]
                            teamInfoArray.append(teamNameFullDict)
                            
                            
                            
                            // TEAM_ABBREVIATION (Dictionary)
                            let teamAbbr = (headersArray[4] as! String)
                            let teamAbbrDict: [String:String] =
                            [
                                teamAbbr : String((rowSetArray[0] as! NSArray)[4])
//                              teamAbbr : String(rowSetArray[0][4])
                            ]
                            teamInfoArray.append(teamAbbrDict)
                            
                            
                            // TEAM_ID (Dictionary)
                            let isTeamID = (headersArray[0] as! String)
                            let teamIDDict: [String:String] =
                            [
                                isTeamID : String((rowSetArray[0] as! NSArray)[0])
//                                isTeamID : String(rowSetArray[0][0])
                            ]
                            teamInfoArray.append(teamIDDict)
                            
                            
                            // Set key to team name (ex. "Los Angeles Lakers")
                            // var currentTeam = String(rowSetArray[0][2]) + " " + String(rowSetArray[0][3])
                            
                            // Set key to team ID (ex. "1610612747")
                            let currentTeam = String((rowSetArray[0] as! NSArray)[0])
//                            let currentTeam = String(rowSetArray[0][0])
                            
                            teamInfoDict[currentTeam] = teamInfoArray
                            
                        }
                    }
                    
                }
                
                return teamInfoDict
            }
            
            teamInfoDict = getTeamInfo()

            
        } catch let error as NSError {
            print("Error:\n \(error)")
        }
        
        
        
        
        ////////////////////     Player Info - Get Rotoworld URL     \\\\\\\\\\\\\\\\\\\\

        // http://www.rotoworld.com/player/nba/1622/jeff-teague
        
        // DESCRIPTION:
        // Find URL for player page for each NBA player on www.rotoworld.com
        // Need to find each player's Rotoworld page in order to scrape data for player-specific news
        
        let rotoString = "http://www.rotoworld.com/player/nba/"
        let depthURLString = "http://www.rotoworld.com/teams/depth-charts/nba.aspx"
        
        // Find playerURLString
        if let depthURL = NSURL(string: depthURLString) {
            do {
                
                // search string "/player/nba/" shows up extra times after "Highest Searched Players"
                //  set "Highest Searched Players" as end of relevant web content, then
                //  index 0 = content before "Highest Searched Players" (relevant) and
                //  index 1 = content after "Highest Searched Players" (not relevant)
                
                let webContent = try String(contentsOfURL: depthURL, encoding: NSUTF8StringEncoding)
                let endWebContent = webContent.componentsSeparatedByString("Highest Searched Players")
                let playerContent = endWebContent[0]
                
                // Index 1 through last in array holds player URL string for each player
                let playerURLArray = playerContent.componentsSeparatedByString("/player/nba/")
                
                if playerURLArray.count > 1 {
                    
                    // Find all player URL strings for each PLAYER in playerURLArray (all NBA players)
                    for n in 1 ..< playerURLArray.count {
                        
                        var nameIfInjured = ""
                        
                        let getNameURL = playerURLArray[n].componentsSeparatedByString("</a>")
                        if getNameURL.count > 1 {
                            let nameURL         = getNameURL[0]                              //  933/kirk-hinrich'>Kirk Hinrich
                            let nameURLArray    = nameURL.componentsSeparatedByString("'>")  //  [0] = 933/kirk-hinrich, [1] = Kirk Hinrich
                            let urlString       = rotoString + nameURLArray[0]
                            let playerName      = nameURLArray[1]
                            
                            rotoDict[playerName] = urlString
                            
                            nameIfInjured = playerName
                        }
                        
                        
                        // Use this loop (playerActive, playerInjured) if you want to keep track of injuries

                        let playerInjured = playerURLArray[n].componentsSeparatedByString("<span>Sidelined</span>")

                        if playerInjured.count > 1 {
                            
                            // Player is injured
                            injuredPlayers.append(nameIfInjured)

                        }


                    }

                }

            } catch {
                print("Error : \(error)")
            }

        } else {
            //print("Error: \(depthURLString) doesn't  URL")
        }

        
        
        // DESCRIPTION:
        // Once all relevant data is found, commit to Realm

        ////////////////////     REALM - Object 1 (NBA Player List)     \\\\\\\\\\\\\\\\\\\\

        // DESCRIPTION:
        // Each player commit includes his player & team info
        
        let allPlayers = NBAPlayerList()
        for x in 0 ..< playerNameArray.count {

            let pName = playerNameArray[x]
            let pInfo = PlayerSummary()
            let tInfo = TeamSummary()
            let currentPlayer = NBAPlayer()
            
            pInfo.name          = playerInfoDict[pName]![0]["PLAYER_NAME"]!
            pInfo.number        = playerInfoDict[pName]![1]["NUM"]!
            pInfo.position      = playerInfoDict[pName]![2]["POSITION"]!
            pInfo.playerID      = playerInfoDict[pName]![3]["PLAYER_ID"]!
            pInfo.teamID        = playerInfoDict[pName]![4]["TEAM_ID"]!
            if rotoDict[pName] != nil {
                pInfo.rotoURLString = rotoDict[pName]!
            }
            if injuredPlayers.contains(pName) {
                pInfo.injured = true
            }
            
            tInfo.city          = teamInfoDict[pInfo.teamID]![0]["TEAM_CITY"]!
            tInfo.name          = teamInfoDict[pInfo.teamID]![1]["TEAM_NAME"]!
            tInfo.teamName      = teamInfoDict[pInfo.teamID]![2]["TEAM_NAME_FULL"]!
            tInfo.abbreviation  = teamInfoDict[pInfo.teamID]![3]["TEAM_ABBREVIATION"]!
            tInfo.teamID        = teamInfoDict[pInfo.teamID]![4]["TEAM_ID"]!
            
            currentPlayer.playerName    = pName
            currentPlayer.playerInfo    = pInfo
            currentPlayer.teamInfo      = tInfo
            
            // Players moving in/out of the league will be nulled, check accordingly
            if (pInfo.name != "<null>") {
                allPlayers.players.append(currentPlayer)
            }
            
        }
        
        
        
        
        ////////////////////     REALM - Object 2 (Game Logs)     \\\\\\\\\\\\\\\\\\\\

        // DESCRIPTION:
        // 5 most recent game logs are stored for each player
        
        let gameLogsDisplayed = GameLogs()
        
        // Set i to # of rows displayed for game log stats
        // Currently: NUM_STATS
        for i in 0 ..< NUM_STATS {
            
            let stat = Stats()
            stat.stat = "nil"
            gameLogsDisplayed.log1.append(stat)
            gameLogsDisplayed.log2.append(stat)
            gameLogsDisplayed.log3.append(stat)
            gameLogsDisplayed.log4.append(stat)
            gameLogsDisplayed.log5.append(stat)

        }
        
        
        
        
        ////////////////////     REALM - Object 3 (Current Player Selected)     \\\\\\\\\\\\\\\\\\\\

        // DESCRIPTION:
        // Keeps track of which player the user has selected from the player list
        
        let playerClicked = PlayerSelected()
        playerClicked.playerName = ""
        
        
        
        
        ////////////////////     REALM - Object 4 (Matchups)     \\\\\\\\\\\\\\\\\\\\
        
        // DESCRIPTION:
        // Finds which teams the player will be facing off against in the current week (regular season only)
        
        // Find all games for next 7 days
        // Matchup times = EST
        
        let myURLString = "http://www.fantasypros.com/nba/schedules/index.php"
        
        if let myURL = NSURL(string: myURLString) {
            do {
                let webContent = try String(contentsOfURL: myURL, encoding: NSUTF8StringEncoding)
                
                // Index 1 through last in dateArray holds matchup data for each day
                let dateArray = webContent.componentsSeparatedByString("<th colspan=\"3\" style=\"background-color: #ddd; text-align: center;\">")
                if dateArray.count > 0 {
                    
                    // Find all matchups for each DATE in dateArray (date range = next 7 days)
                    for i in 1 ..< dateArray.count {
                        var homeTeamsData = [String]()
                        var awayTeamsData = [String]()
                        var timeData = [String]()
                        
                        var homeTeamsArray = [String]()
                        var awayTeamsArray = [String]()
                        var matchupTimeArray = [String]()
                        
                        let dailyMatchupData = dateArray[i].componentsSeparatedByString("<td style=\"text-align: right; font-size: 15px;\">")
                        let matchupDateData = dateArray[i].componentsSeparatedByString("</th>")
                        let matchupDate = matchupDateData[0]
                        
                        // Find all team names for matchups that fall within the current date
                        for j in 1 ..< dailyMatchupData.count {
                            let teamsArray = dailyMatchupData[j].componentsSeparatedByString("alt=\"")
                            let timeArray = dailyMatchupData[j].componentsSeparatedByString("<td style=\"border-left: none; vertical-align: middle; font-size: 13px;\">")
                            awayTeamsData.append(teamsArray[1])
                            homeTeamsData.append(teamsArray[2])
                            timeData.append(timeArray[1])
                        }
                        
                        // Get team names, save into current day's team arrays
                        for k in 0 ..< homeTeamsData.count {
                            let h = homeTeamsData[k].componentsSeparatedByString("\" class=\"fp-icon\"")
                            let a = awayTeamsData[k].componentsSeparatedByString("\" class=\"fp-icon\"")
                            let t = timeData[k].componentsSeparatedByString("</td>")
                            homeTeamsArray.append(h[0])
                            awayTeamsArray.append(a[0])
                            matchupTimeArray.append(t[0])
                            
                        }
                        
                        // Make Schedule object for current day's matchups
                        for m in 0 ..< homeTeamsArray.count {
                            
                            let currentMatchup = Matchup()
                            currentMatchup.date = matchupDate
                            currentMatchup.time = matchupTimeArray[m]
                            currentMatchup.homeTeam = homeTeamsArray[m]
                            currentMatchup.awayTeam = awayTeamsArray[m]
                            
                            // Add currentMatchup to Realm
                            try! realm.write {
                                realm.add(currentMatchup)
                            }
                            
                        }
                        
                    }
                    
                }
                
            } catch {
                print("Error : \(error)")
            }
            
        } else {
            //print("Error: \(myURLString) doesn't  URL")
        }
        
        
        
        
        ////////////////////     REALM - Writes     \\\\\\\\\\\\\\\\\\\\

        try! realm.write {
            realm.add(allPlayers)
            realm.add(playerClicked)
            realm.add(gameLogsDisplayed)
        }
    

        return true
        
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

