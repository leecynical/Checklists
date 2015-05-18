//
//  DataModel.swift
//  Checklists
//
//  Created by 李金钊 on 15/3/10.
//  Copyright (c) 2015年 lijinzhao. All rights reserved.
//

import Foundation

class DataModel{
    var lists = [Checklist]()
    
    init(){
        loadChecklists()
        registerDefaults()
        handleFirstTime()
    }
    // compare string.name ascendlingly
    func sortChecklists(){
        lists.sort({ checklist1, checklist2 in return
            checklist1.name.localizedStandardCompare(checklist2.name) ==
                                    NSComparisonResult.OrderedAscending })
    }
    
    class func nextChecklistItemID() -> Int {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let itemID = userDefaults.integerForKey("ItemID")
        userDefaults.setInteger(itemID + 1, forKey: "ItemID")
        userDefaults.synchronize()
        return itemID
    }
    
    func registerDefaults(){
        let dictionary = ["ChecklistIndex": -1, "FirstTime": true, "ChecklistItemID": 0]
        
        NSUserDefaults.standardUserDefaults().registerDefaults(dictionary)
    }
    
    func handleFirstTime(){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let firstTime = userDefaults.boolForKey("FirstTime")
        if firstTime{
            let checklist = Checklist(name: "List")
            lists.append(checklist)
            indexOfSelectedChecklist = 0
            userDefaults.setBool(false , forKey: "FirstTime")
        }
    }
    
    var indexOfSelectedChecklist: Int{
        get{
            return NSUserDefaults.standardUserDefaults().integerForKey("ChecklistIndex")
        }
        set{
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: "ChecklistIndex")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func documentsDirectory() -> String{
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as! [String]
        return paths[0]
    }
    
    func dataFilePath() -> String{
        return documentsDirectory().stringByAppendingPathComponent("Checklists.plist")
    }
    
    func saveChecklists(){
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(lists, forKey: "Checklists")
        archiver.finishEncoding()
        data.writeToFile(dataFilePath(), atomically: true)
    }
    
    func loadChecklists(){
        let path = dataFilePath()
        if NSFileManager.defaultManager().fileExistsAtPath(path){
            if let data = NSData(contentsOfFile: path){
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                lists = unarchiver.decodeObjectForKey("Checklists") as! [Checklist]
                unarchiver.finishDecoding()
                sortChecklists()
            }
        }
    }
}
