//
//  PlayerStatsCollectionViewCell.swift
//  fantasy_bball_v1.2
//
//  Created by Kevin Ho on 3/4/16.
//  Copyright © 2016 DankApp. All rights reserved.
//

import UIKit
import RealmSwift

class PlayerStatsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var statVal1: UILabel!
    @IBOutlet weak var statVal2: UILabel!
    @IBOutlet weak var statVal3: UILabel!
    @IBOutlet weak var statVal4: UILabel!
    @IBOutlet weak var statVal5: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
