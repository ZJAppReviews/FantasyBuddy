//
//  PlayerInfoTableViewCell.swift
//  FantasyBuddy
//
//  Created by Kevin Ho on 3/14/16.
//  Copyright © 2016 Kevin Ho. All rights reserved.
//
//
//  Notes: Loads player image & info in first cell of PSTVC
//

import UIKit
import RealmSwift

class PlayerInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var playerPic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var bio: UILabel!
    @IBOutlet weak var opponent: UILabel!
    @IBOutlet weak var injuryStatus: UILabel!
    @IBOutlet weak var gamesRemaining: UILabel!
    @IBOutlet weak var teamsRemaining: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func getInjuryStatus(name: String) -> String {
        
        // Scrap relevant data from Rotoworld -- subject to update
        let injuriesURLString = "http://www.rotoworld.com/teams/injuries/nba/all/"
        var status = ""
        
        if let injuriesURL = NSURL(string: injuriesURLString) {
            do {
                
                // Component indexing (i.e. [0] = data before "x", [1] = data after
                let webContent = try String(contentsOfURL: injuriesURL, encoding: NSUTF8StringEncoding)
                let endWebContent = webContent.componentsSeparatedByString("Highest Searched Players")
                let playerContent = endWebContent[0]
                
                // URL data for each player at [1] - [n]
                let playerURLArray = playerContent.componentsSeparatedByString("/player/nba/")
                
                if playerURLArray.count > 1 {
                    
                    // Find URL string for all players in array
                    for n in 1 ..< playerURLArray.count {
                        
                        var injuredPlayer = ""
                        
                        let getNameURL = playerURLArray[n].componentsSeparatedByString("</a>")
                        if getNameURL.count > 1 {
                            let nameURL         = getNameURL[0]                                 //  933/kirk-hinrich'>Kirk Hinrich
                            let nameURLArray    = nameURL.componentsSeparatedByString("\">")    //  [0] = 933/kirk-hinrich, [1] = Kirk Hinrich
                            injuredPlayer       = nameURLArray[1]
                            
                            // Single apostrophe (') error case:
                            if injuredPlayer.containsString("&#39;") {
                                let formatted = injuredPlayer.stringByReplacingOccurrencesOfString("&#39;", withString: "'", options: NSStringCompareOptions.LiteralSearch, range: nil)
                                injuredPlayer = formatted
                            }
                        }
                        
                        if injuredPlayer == name {
                            let getStatus = playerURLArray[n].componentsSeparatedByString("<div class='impact'>")
                            if getStatus.count > 1 {
                                let statusData1 = getStatus[1]
                                let statusData2 = statusData1.componentsSeparatedByString("</div><div class='date'>")
                                status = statusData2[0]
                            }
                        }
                        
                    }
                }
            } catch {
                print("Error : \(error)")
            }
            
        } else {
        }
        
        return status
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
        ///////////////////     Initialization    \\\\\\\\\\\\\\\\\\\\

        let nameRealm = realm.objects(PlayerSelected)
        let playerName = nameRealm[0].playerName
        let player = realm.objects(NBAPlayer).filter("playerName = %@", playerName)
        let player_id = player[0].playerInfo?.playerID
        let injured = player[0].playerInfo?.injured
        
        

        
        ///////////////////     Step 1: Set Player Pic    \\\\\\\\\\\\\\\\\\\\
        
        var player_code = String()
        
        // Find player code from
        // http://stats.nba.com/stats/commonplayerinfo/?playerid=203501
        
        let endpoint = "commonplayerinfo"
        let params = "PlayerID=" + player_id!
        let urlString = "http://stats.nba.com/stats/" + endpoint + "/?" + params
        let url = NSURL(string: urlString)
        let data: NSData? = NSData(contentsOfURL: url!)
        
        do
        {
            if let jsonResult: NSDictionary =
                try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
            {
                let rsArray = jsonResult["resultSets"] as! NSArray
                let resultSets = rsArray[0]
                let rsName = resultSets["name"]
                if rsName as! String == "CommonPlayerInfo"
                {
                    let rowSetArr = resultSets["rowSet"] as! NSArray
                    player_code = (rowSetArr[0] as! NSArray)[21] as! String
//                  player_code = rowSetArr[0][21] as! String
                    
                }
            }
        } catch let error as NSError {
            print("Error:\n \(error)")
        }
        
        // Populate image:
        let image_url = NSURL(string: "http://i.cdn.turner.com/nba/nba/.element/img/2.0/sect/statscube/players/large/" + player_code + ".png")
        if let data = NSData(contentsOfURL: image_url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
        {
            let pic = UIImage(data: data)
            self.playerPic.image = pic
        }
    
 
        
        
        ///////////////////     Step 2: Set Player Info    \\\\\\\\\\\\\\\\\\\\

        ///////////////////     Initialization    \\\\\\\\\\\\\\\\\\\\
        
        // NOTES:
        //  If daylight savings = active, then - 1 hour to PST
        //  Usually, PST = -8 UTC
        //  W/ DST,  PST = -7 UTC
        
        // All NBA Teams
        let teamRealm = realm.objects(TeamSummary)
        
        // NBA Schedule for current week
        let teams = realm.objects(Matchup)
        
        // Team name of current selected player
        let teamName = player[0].teamInfo!.city + " " + player[0].teamInfo!.name
        let playerNum = player[0].playerInfo!.number
        
        // This week's matchups for selected player
        let matchups = teams.filter("homeTeam = %@ OR awayTeam = %@", teamName, teamName)
        let currentDate = NSDate() // Today
        let dateFormatter = NSDateFormatter()
        let matchingComponents = NSDateComponents()
        matchingComponents.weekday = 2 // Monday
        
        // Use for weekly reset
        let comingMonday =  NSCalendar.currentCalendar().nextDateAfterDate(
            currentDate,
            matchingComponents: matchingComponents,
            options:.MatchNextTime)
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let components = calendar!.components([.Weekday], fromDate: currentDate)
        let today = components.weekday // 1 == Monday
        
        var teamsAgainstArray = [String]()
        var convertedDatesArray = [NSDate]()
        var gamesThisWeek = false
        
        
        
        ///////////////////     Matchups (for current week)    \\\\\\\\\\\\\\\\\\\\
        for n in 0 ..< matchups.count {
            
            let temp = matchups[n].date
            //let tempDate = temp.substringWithRange(Range<String.Index>(start: temp.startIndex, end: temp.endIndex.advancedBy(-2)))
            let tempDate = temp.substringWithRange(Range<String.Index>(temp.startIndex ..< temp.endIndex.advancedBy(-2)))
            let tempTime = matchups[n].time
            let checkDate = tempDate + " " + CURRENT_YEAR + " " + tempTime + " EST"
            
            dateFormatter.dateFormat = "EEEE, MMMM dd yyyy h:mm a zzz"  // Sunday, March 27 2016 8:00 pm EST
            let convertedDate = dateFormatter.dateFromString(checkDate)
            if currentDate.timeIntervalSinceReferenceDate < convertedDate!.timeIntervalSinceReferenceDate {
                
                // Date still falls within the current week (is within upcoming Sunday @ 11:59pm)
                if convertedDate!.timeIntervalSinceReferenceDate < comingMonday?.timeIntervalSinceReferenceDate {
                    
                    gamesThisWeek = true
                    if matchups[n].homeTeam == teamName {
                        let away = matchups[n].awayTeam
                        let convert = teamRealm.filter("teamName = %@", away)
                        teamsAgainstArray.append(convert[0].abbreviation)
                        //teamsAgainstArray.append("vs. " + convert[0].abbreviation)
                    }
                    else {
                        let home = matchups[n].homeTeam
                        let convert = teamRealm.filter("teamName = %@", home)
                        teamsAgainstArray.append("@" + convert[0].abbreviation)
                    }
                    convertedDatesArray.append(convertedDate!)
                }
                //print("currentDate is EARLIER than convertedDate")
            }
            else if currentDate.timeIntervalSinceReferenceDate > convertedDate!.timeIntervalSinceReferenceDate {
                //print("currentDate is LATER than convertedDate")
            }
            else {
                //print("Same dates")
            }

        }
        
        var first_opponent_abbr = ""
        var day_check = ""

        if (!convertedDatesArray.isEmpty) {
        
        // If game is TODAY or TOMORROW, replace day with "Today" or "Tomorrow"
        let upcoming_game_date = convertedDatesArray[0]
        let upcoming_game_date_components = calendar!.components([.Weekday], fromDate: upcoming_game_date)
        let next_game_day = upcoming_game_date_components.weekday

        switch next_game_day {
            case 1:
                day_check = "Monday"
            case 2:
                day_check = "Tuesday"
            case 3:
                day_check = "Wednesday"
            case 4:
                day_check = "Thursday"
            case 5:
                day_check = "Friday"
            case 6:
                day_check = "Saturday"
            case 7:
                day_check = "Sunday"
            default:
                break
        }
        
        if next_game_day == today { day_check = "Today" }
        if next_game_day == (today + 1) { day_check = "Tomorrow" }
        
        first_opponent_abbr = teamsAgainstArray[0].substringFromIndex(teamsAgainstArray[0].endIndex.advancedBy(-3))
        
        } else {

            day_check = ""
            first_opponent_abbr = ""

        }
        
        
        
        ///////////////////     Formatting & Writes    \\\\\\\\\\\\\\\\\\\\
        
        // Opponent
        var opp = ""
        if (!teamsAgainstArray.isEmpty) {
            let team1 = teamsAgainstArray[0]
            let char1 = String(team1[team1.startIndex.advancedBy(0)])
            if char1 == "@" {
                opp = " @ " + first_opponent_abbr
            }
            else {
                opp = " vs. " + first_opponent_abbr
            }
        } else {
            opp = first_opponent_abbr
        }
        var opponent_text = "No games this week"
        if (!matchups.isEmpty && gamesThisWeek) {
            opponent_text = day_check + opp + " - " + matchups[0].time
        }
        self.opponent.text = opponent_text
        self.opponent.adjustsFontSizeToFitWidth = true
        
        // Name
        var injuredTag = ""
        if injured == true {
            injuredTag = " [INJ]"
            self.injuryStatus.text = "Status: " + getInjuryStatus(playerName)
            self.injuryStatus.adjustsFontSizeToFitWidth = true
        }
        self.name.text = playerName + injuredTag
        self.name.adjustsFontSizeToFitWidth = true
        
        // Player info
        var bio_text = ""
        if (playerNum == "<null>") {
            bio_text = player[0].playerInfo!.position + "  |  " + teamName
        } else {
            bio_text = player[0].playerInfo!.position + "  |  " + teamName + " #" + playerNum
        }
        self.bio.text = bio_text
        self.bio.adjustsFontSizeToFitWidth = true

        if (teamsAgainstArray.isEmpty) {
            self.gamesRemaining.text = ""
            self.teamsRemaining.text = ""
        } else {
            self.gamesRemaining.text = "Games remaining this week: " + String(teamsAgainstArray.count)
            let teamsAgainstText = teamsAgainstArray.joinWithSeparator(", ")
            self.teamsRemaining.text = "Opponents: " + teamsAgainstText
        }
        self.opponent.adjustsFontSizeToFitWidth = true
        self.opponent.adjustsFontSizeToFitWidth = true

    }
    
}

extension String {
    func insert(string:String,ind:Int) -> String {
        return  String(self.characters.prefix(ind)) + string + String(self.characters.suffix(self.characters.count-ind))
    }
}
