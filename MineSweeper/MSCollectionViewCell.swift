//
//  MSCollectionViewCell.swift
//  MineSweeper
//
//  Created by Yuxiang Tang on 2/10/16.
//  Copyright © 2016 Yuxiang Tang. All rights reserved.
//

import Foundation
import UIKit

class MSCollectionViewCell: UICollectionViewCell {
    
    //record how many mines around you
    var label: UILabel!
    
    //record mines around you
    var minesAround: Int!
    
    //record your identity, true: mine; false: normal brick
    var isMine: Bool!
    
    
    //show top layer bricks
    var topView: UIImageView!
    
    //show flag image when double tapped
    var middleView: UIImageView!
    
    
    var bottomView: UIImageView!
    
    
    //used to tell if this cell should be uncovered
    //two scenarios when a cell should be uncovered:
    //1. the cell contains mine and user steps on to the cell and game is over
    //2. the cell doesn't contain mine and the adjacent cells are uncovered
    var shouldUncover: Bool!
    
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
        
        
    }
    
    override init(frame: CGRect){
        super.init(frame:frame)
        self.backgroundColor = UIColor.lightGrayColor()
        self.isMine = false
        
        self.setupViews()
        
    }
    
    func setupViews(){
        
        self.bottomView = UIImageView()
        self.bottomView.frame = CGRectMake(0, 0, self.bounds.width, self.bounds.height)
        self.bottomView.image = UIImage(named: "grid-notMine")
        self.addSubview(self.bottomView)
        
        
        self.label = UILabel()
        self.label.backgroundColor = UIColor.clearColor()
        self.label.frame = CGRectMake(self.bounds.width / 8 , self.bounds.height / 8, self.bounds.width * 6 / 8, self.bounds.height * 6 / 8)
        self.label.textAlignment = .Center
        self.label.font = UIFont.boldSystemFontOfSize(25)
        self.addSubview(self.label)
        
        self.middleView = UIImageView()
        self.middleView.frame = CGRectMake(0, 0, self.bounds.width, self.bounds.height)
        self.middleView.image = UIImage(named: "flag")
        self.addSubview(self.middleView)
        
        self.topView = UIImageView()
        self.topView.frame = CGRectMake(0, 0, self.bounds.width, self.bounds.height)
        self.topView.image = UIImage(named: "grid-unknown")
        self.addSubview(self.topView)

    
    }

    
    
}
