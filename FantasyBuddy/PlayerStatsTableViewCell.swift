//
//  PlayerStatsTableViewCell.swift
//  fantasy_bball_v1.2
//
//  Created by Kevin Ho on 3/3/16.
//  Copyright © 2016 DankApp. All rights reserved.
//

import UIKit
import RealmSwift



class PlayerStatsTableViewCell: UITableViewCell {

    @IBOutlet private weak var collectionView: UICollectionView!

}

extension PlayerStatsTableViewCell {
    
    func setCollectionViewDataSourceDelegate<D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>(dataSourceDelegate: D, forRow row: Int) {
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.setContentOffset(collectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        collectionView.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        set {
            collectionView.contentOffset.x = newValue
        }
        
        get {
            return collectionView.contentOffset.x
        }
    }
}