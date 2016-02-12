//
//  MainViewController.swift
//  MineSweeper
//
//  Created by Yuxiang Tang on 2/10/16.
//  Copyright © 2016 Yuxiang Tang. All rights reserved.
//

import Foundation
import UIKit

class MainViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIGestureRecognizerDelegate  {
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    //UI elements
    var restartButton: UIButton!
    var cheatButton: UIButton!
    var endGameView: UILabel!
    
    //collection view
    var mainCollectionView: UICollectionView!
    var identifier = "cell"
    
    //data source
    var mineDataArray = [Int]()
    var bfsArr = [[Int]]()
    var cheatModeArr = [[Int]]()
    //0: covered    1: uncovered    2: marked flag  3: marked question
    var shouldUncover = [[Int]]()
    
    var longPressLock: Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupRestartButton()
        self.setupMainCollectionView()
        self.setupEndGameView()
        self.setupCheatButton()
        
        let lpgr = MSLongPressGesture(target: self, action: "handleLongPress:")
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.mainCollectionView.addGestureRecognizer(lpgr)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.generateMineData()
        self.setBFSArr()
    }

    
    
    /*
        Some Main Setups
    */
    
    func setupMainCollectionView(){
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 1.0
        flowLayout.minimumLineSpacing = 1.0
        flowLayout.sectionInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        
        var collectionViewFrame = CGRectMake(10, self.screenHeight/2 - (self.screenWidth - 20)/2, self.screenWidth - 20, self.screenWidth - 20)
        self.mainCollectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: flowLayout)
        
        self.mainCollectionView.registerClass(MSCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: self.identifier)
        self.mainCollectionView.delegate = self
        self.mainCollectionView.dataSource = self
        self.mainCollectionView.backgroundColor = UIColor.redColor()
        self.view.addSubview(self.mainCollectionView)
    
    }
    
    func setupRestartButton(){
        self.restartButton = UIButton(type: UIButtonType.Custom)
        self.restartButton.frame = CGRectMake(self.screenWidth / 2 - 30, self.screenHeight - 80, 60, 60)
        self.restartButton.setBackgroundImage(UIImage(named: "smile"), forState: UIControlState.Normal)
        self.restartButton.addTarget(self, action: "restartButtonOnClick:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(self.restartButton)
    
    }
    
    func setupCheatButton(){
        self.cheatButton = UIButton()
        self.cheatButton.frame = CGRectMake(self.screenWidth / 2 - 40, 80, 80, 40)
        self.cheatButton.setTitle("Cheat", forState: UIControlState.Normal)
        self.cheatButton.backgroundColor = UIColor.lightGrayColor()
        self.cheatButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        self.cheatButton.layer.cornerRadius = 15
        self.cheatButton.layer.borderColor = UIColor.blackColor().CGColor
        self.cheatButton.layer.borderWidth = 1.0
        self.cheatButton.clipsToBounds = true
        self.view.addSubview(self.cheatButton)
        
        
        self.cheatButton.addTarget(self, action: "cheatButtonTouchDown:", forControlEvents: UIControlEvents.TouchDown)
        self.cheatButton.addTarget(self, action: "cheatButtonTouchUpInside:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func setupEndGameView(){
        self.endGameView = UILabel()
        self.endGameView.frame = self.mainCollectionView.frame
        self.endGameView.backgroundColor = UIColor.clearColor()
        self.endGameView.textColor = UIColor.blackColor()
        self.endGameView.font = UIFont.boldSystemFontOfSize(28)
        self.endGameView.textAlignment = .Center
        self.view.addSubview(self.endGameView)
        self.endGameView.hidden = true
    }
    
    /*
        Generate 10 Random Mines
    */
    
    func restartButtonOnClick(sender: UIButton){
        self.generateMineData()
        self.mainCollectionView.allowsSelection = true
        self.endGameView.hidden = true
        self.restartButton.setBackgroundImage(UIImage(named: "smile"), forState: UIControlState.Normal)
    }
    
    func generateMineData(){
        self.mineDataArray.removeAll()
       self.mineDataArray = uniqueRandoms(10, minNum: 1, maxNum: 64)
        print(mineDataArray)
        self.setBFSArr()
    }
    
    func uniqueRandoms(numberOfRandoms: Int, minNum: Int, maxNum: UInt32) -> [Int] {
        var uniqueNumbers = Set<Int>()
        while uniqueNumbers.count < numberOfRandoms {
            uniqueNumbers.insert(Int(arc4random_uniform(maxNum)) + minNum)
        }
        
        return Array(uniqueNumbers).sort()
    }
    
    
    /*
        Cheat Button Action
    */
    func cheatButtonTouchDown(sender: UIButton){
        print("touch down!")
    
        //copy the previous states
        for(var i=0;i<ROWS;i++){
            for(var j=0;j<COLUMNS;j++){
                self.cheatModeArr[i][j] = self.shouldUncover[i][j]
            }
        }
    
        for(var i=0;i<ROWS;i++){
            for(var j=0;j<COLUMNS;j++){
                if self.bfsArr[i][j] == -1 {
                    self.shouldUncover[i][j] = 1
                }
            }
        }
        self.mainCollectionView.reloadData()
        
    }
    
    func cheatButtonTouchUpInside(sender: UIButton){
        print("touch up inside")
        
        for(var i=0;i<ROWS;i++){
            for(var j=0;j<COLUMNS;j++){
                self.shouldUncover[i][j] = self.cheatModeArr[i][j]
            }
        }
        self.mainCollectionView.reloadData()
    }
    
    
    /*
        UICollectionView Delegates
    
    */
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 64
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        
        var m = indexPath.item / ROWS
        var n = indexPath.item % COLUMNS
        
        
        switch self.shouldUncover[m][n] {
            
        case 1:
            //uncover the cell
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.identifier, forIndexPath: indexPath) as! MSCollectionViewCell
            
            print("cell should uncover")
            print(m)
            print(n)
            
            cell.topView.hidden = true
            cell.middleView.hidden = true
            if self.bfsArr[m][n] == -1 {
                cell.label.hidden = true
                cell.bottomView.image = UIImage(named: "mine")
            } else {
                cell.label.hidden = false
                cell.label.text = String(self.bfsArr[m][n])
                cell.bottomView.image = UIImage(named: "grid-notMine")
            }
            return cell
            
        case 0:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.identifier, forIndexPath: indexPath) as! MSCollectionViewCell
            
            //cover the cell
            cell.topView.hidden = false
            cell.middleView.hidden = false
            
            //check if this cell contains mine
            if self.bfsArr[m][n] == -1 {
                cell.label.hidden = true
                cell.bottomView.image = UIImage(named: "mine")
                
            }else {
                cell.label.hidden = false
                cell.label.text = String(self.bfsArr[m][n])
                cell.bottomView.image = UIImage(named: "grid-notMine")
            }
            
            return cell
            
            
        case 2:
            //cell marked with flag
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.identifier, forIndexPath: indexPath) as! MSCollectionViewCell
            
            cell.topView.hidden = true
            cell.middleView.hidden = false
            cell.middleView.image = UIImage(named: "flag")
            return cell
            
        case 3:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.identifier, forIndexPath: indexPath) as! MSCollectionViewCell
            
            cell.topView.hidden = true
            cell.middleView.hidden = false
            cell.middleView.image = UIImage(named: "question")
            return cell
            
        default:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.identifier, forIndexPath: indexPath) as! MSCollectionViewCell
            return cell
        }
        
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let myLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        var myWidth : CGFloat = 0.0
        
        if(collectionView == self.mainCollectionView) {
            myWidth = (self.mainCollectionView.frame.width - myLayout.minimumInteritemSpacing * 7) / 8
        }
        
        return CGSizeMake(myWidth,myWidth)
        
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MSCollectionViewCell
    
        var m = indexPath.item / ROWS
        var n = indexPath.item % COLUMNS
        
        print(m)
        print(n)
        
        
        switch self.shouldUncover[m][n]{
        case 0:
            //the cell is not uncovered
            if self.bfsArr[m][n] == -1 {
                //game end
                self.uncoverMines()
                self.mainCollectionView.reloadData()
                self.gameEnd()
            }else {
                print("uncover cells")
                //show relevant result
                self.uncoverTiles(m, colNumber: n)
                self.mainCollectionView.reloadData()
                
            }
            break
        case 1:
            //the cell is already uncovered
            print("cell already uncovered")
            break
        case 2:
            //the cell is marked with flag
            //turn it to question mark
            self.shouldUncover[m][n] = 3;
            self.mainCollectionView.reloadItemsAtIndexPaths([indexPath])
            if self.checkGameEnd() == true {
                self.gameWin()
            }
            break
        case 3:
            //the cell is marked with question
            //uncover the cell 
            //do same thing as case 0
            if self.bfsArr[m][n] == -1 {
                //game end
                self.uncoverMines()
                self.mainCollectionView.reloadData()
                print("game end")
            }else {
                print("uncover cells")
                //show relevant result
                self.uncoverTiles(m, colNumber: n)
                self.mainCollectionView.reloadData()
            }
            
            break
        default:
            break
        }
        
        
        if self.shouldUncover[m][n]==0{
            //the cell is not uncovered
            if self.bfsArr[m][n] == -1 {
                //game end
                self.uncoverMines()
                self.mainCollectionView.reloadData()
                print("game end")
            }else {
                print("uncover cells")
                //show relevant result
//                cell.topView.hidden = true
//                cell.middleView.hidden = true
                self.uncoverTiles(m, colNumber: n)
                self.mainCollectionView.reloadData()
            }
        }else if self.shouldUncover[m][n] == 2{
            //when the cell is being marked
            
        }else {
            print("cell already uncovered")
        }
        
        
        
        if self.checkGameEnd() == true {
            self.gameWin()
        }
        
        
        
    }
    
    /*
        Uncover Relevant Tiles
    */
    func uncoverMines(){
        for(var i = 0;i < ROWS; i++){
            for(var j = 0; j < COLUMNS; j++){
                if self.bfsArr[i][j] == -1 {
                    self.shouldUncover[i][j] = 1
                }
            }
        }
        
//        for item in self.mineDataArray {
//            var m: Int = (item-1) / ROWS
//            var n: Int = (item-1) % COLUMNS
//            self.shouldUncover[m][n] = 1
//        }
    }
    
    func setBFSArr(){
        
        self.bfsArr.removeAll()
        self.shouldUncover.removeAll()
        self.cheatModeArr.removeAll()
        
        for(var i = 0; i < COLUMNS; i++){
            self.bfsArr.append(Array(count:ROWS, repeatedValue:Int()))
            self.shouldUncover.append(Array(count:ROWS, repeatedValue:Int()))
            self.cheatModeArr.append(Array(count: ROWS, repeatedValue: Int()))
        }
        
        var cur: Int = 1
        for(var i=0; i < COLUMNS; i++){
            for(var j=0; j < ROWS; j++){
                
                //0 means shouldn't uncover
                self.shouldUncover[i][j] = 0
                
                
                self.bfsArr[i][j]=0
                
                for item in self.mineDataArray where item == cur {
                    //this item is a mine, label it -1
                    self.bfsArr[i][j] = -1
                }
                
                if self.bfsArr[i][j]==0 {
                    self.bfsArr[i][j] = self.checkAdjacent(cellIndex: cur)
                }
                
                cur++
            }
        }
        
        for(var i=0; i < COLUMNS; i++){
            for(var j=0; j < ROWS; j++){
                print(self.bfsArr[i][j])
            }
        }
        
        
        self.mainCollectionView.reloadData()
    }
    
    
    func uncoverTiles(rowNumber: Int, colNumber: Int){
        
        if (rowNumber < 0 || rowNumber >= ROWS || colNumber < 0 || colNumber >= COLUMNS ){
            //out of bounds
            return
        }
        
        if self.shouldUncover[rowNumber][colNumber] == 1 {
            return
        }
        
        if self.bfsArr[rowNumber][colNumber] == -1 {
            return
        }
        
        if self.bfsArr[rowNumber][colNumber] > 0 {
            //adjacent contains mines
            print("adjacent contain mines")
            self.shouldUncover[rowNumber][colNumber] = 1
        }else if self.bfsArr[rowNumber][colNumber] == -1 {
            //this is a mine
            self.shouldUncover[rowNumber][colNumber] = 0
        }else {
            print("no mines around")
            self.shouldUncover[rowNumber][colNumber] = 1
            self.uncoverTiles(rowNumber - 1, colNumber: colNumber)
            self.uncoverTiles(rowNumber + 1, colNumber: colNumber)
            self.uncoverTiles(rowNumber, colNumber: colNumber - 1)
            self.uncoverTiles(rowNumber, colNumber: colNumber + 1)
            self.uncoverTiles(rowNumber - 1, colNumber: colNumber - 1)
            self.uncoverTiles(rowNumber + 1, colNumber: colNumber + 1)
            self.uncoverTiles(rowNumber - 1, colNumber: colNumber + 1)
            self.uncoverTiles(rowNumber + 1, colNumber: colNumber - 1)
        }
        
    }
    
    
    
    /*
    Check Adjacent Tiles
    */
    func checkAdjacent(cellIndex i: Int) -> Int {
        
        var arr = [Int]()
        var count: Int = 0
        
        if i == 1 {
            arr.append(i+1)
            arr.append(i+8)
            arr.append(i+9)
        } else if i == 8 {
            arr.append(i-1)
            arr.append(i+8)
            arr.append(i+7)
        } else if i == 57 {
            arr.append(i-8)
            arr.append(i+1)
            arr.append(i-7)
        } else if i == 64 {
            arr.append(i-1)
            arr.append(i-8)
            arr.append(i-9)
        } else if i < 8 && i > 1 {
            arr.append(i+7)
            arr.append(i+9)
            arr.append(i-1)
            arr.append(i+1)
            arr.append(i+8)
        } else if i < 64 && i > 57 {
            arr.append(i-9)
            arr.append(i-7)
            arr.append(i-1)
            arr.append(i+1)
            arr.append(i-8)
        } else if i % 8 == 0 {
            arr.append(i-9)
            arr.append(i+7)
            arr.append(i-8)
            arr.append(i+8)
            arr.append(i-1)
        } else if i % 8 == 1{
            arr.append(i-7)
            arr.append(i+9)
            arr.append(i+1)
            arr.append(i+8)
            arr.append(i-8)
        } else {
            arr.append(i-9)
            arr.append(i-8)
            arr.append(i-7)
            arr.append(i-1)
            arr.append(i+1)
            arr.append(i+7)
            arr.append(i+8)
            arr.append(i+9)
        }
        
        
        for number in arr {
            for item in self.mineDataArray where item == number {
                count++
            }
        }
        
        return count
    }
    
    /*
        Long Press on Cells
    
    */
    
    
    
//    @IBAction func longPress(gesture: MyLongPressGesture) {
//        if gesture.state == .Began {
//            gesture.startTime = NSDate()
//        }
//        else if gesture.state == .Ended {
//            let duration = NSDate().timeIntervalSinceDate(gesture.startTime!)
//            println("duration was \(duration) seconds")
//        }
//    }

    
    
    
    func handleLongPress(gestureReconizer: MSLongPressGesture) {
        
        
        if gestureReconizer.state == UIGestureRecognizerState.Began {
            gestureReconizer.startTime = NSDate()
            print(gestureReconizer.startTime)
            self.longPressLock = true
        }
        
        if gestureReconizer.state == UIGestureRecognizerState.Changed {
            
            let duration = NSDate().timeIntervalSinceDate(gestureReconizer.startTime!)
            var ms = Int((duration % 1) * 1000)

            if ms > 500 && self.longPressLock == true {
                print("changed!")
                
                let p = gestureReconizer.locationInView(self.mainCollectionView)
                let indexPath = self.mainCollectionView.indexPathForItemAtPoint(p)
                
                if let index = indexPath {
                    var cell = self.mainCollectionView.cellForItemAtIndexPath(index) as! MSCollectionViewCell
                    
                    var m: Int = (indexPath?.item)! / ROWS
                    var n: Int = (indexPath?.item)! % COLUMNS
                    
                    if self.shouldUncover[m][n] == 0 {
                        //change normal tile to flag
                        self.shouldUncover[m][n] = 2
                    }else if self.shouldUncover[m][n] == 3 {
                        //change question tile to normal
                        self.shouldUncover[m][n] = 0
                    }
                    self.longPressLock = false
                    
                    self.mainCollectionView.reloadItemsAtIndexPaths([indexPath!])
                    
                } else {
                    print("Could not find index path")
                }
                
                
            }
            
        }
        
        
        if gestureReconizer.state != UIGestureRecognizerState.Ended {

            if self.checkGameEnd() == true {
                self.gameWin()
            }
            
            return
        }
        
        
        
        
    }
    
    func gameWin(){
        self.endGameView.hidden = false
        self.endGameView.text = "You Win!"
        
        self.restartButton.setBackgroundImage(UIImage(named: "laugh"), forState: UIControlState.Normal)
        
    }
    
    func gameEnd(){
        print("game end")
        self.mainCollectionView.allowsSelection = false
        self.endGameView.hidden = false
        self.endGameView.text = "Game Over"
        self.restartButton.setBackgroundImage(UIImage(named: "cry"), forState: UIControlState.Normal)

    
    }
    
    /*
        Check Game End
    */
    func checkGameEnd() -> Bool{
        
        
        for(var i = 0; i < ROWS; i++){
            for(var j = 0; j < COLUMNS; j++){
                
                if self.bfsArr[i][j] == -1 {
                    //this is a mine
                    if self.shouldUncover[i][j] != 2 {
                        //if any of the mine is not marked with flag
                        return false
                    }
                }else {
                    if self.shouldUncover[i][j] != 1 {
                        //if any of the tile is not uncovered
                        return false
                    }
                }
            }
        }
        return true
    }

    
    
    
}