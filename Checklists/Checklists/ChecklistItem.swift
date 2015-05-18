//
//  ChecklistItem.swift
//  Checklists
//
//  Created by 李金钊 on 15/3/4.
//  Copyright (c) 2015年 lijinzhao. All rights reserved.
//

import Foundation
import UIKit

class ChecklistItem: NSObject,NSCoding {
    var text = ""
    var checked = false
    var dueDate = NSDate()
    var shouldRemind = false
    var itemID: Int
    
    func toggleChecked(){
        checked = !checked
    }
    
    func notificationForThisItem() -> UILocalNotification?{
        let allNotifications = UIApplication.sharedApplication().scheduledLocalNotifications as! [UILocalNotification]
        for notification in allNotifications {
            if let number = notification.userInfo?["itemID"] as? NSNumber{
                if number.integerValue == itemID{
                    return notification
                }
            }
        }
        return nil
    }
    
    func scheduleNotification(){
        let existingNotification = notificationForThisItem()
        if let notification = existingNotification{
            UIApplication.sharedApplication().cancelLocalNotification(notification)
            println("Found an existing notification \(notification)")
        }
        if shouldRemind && dueDate.compare(NSDate()) != NSComparisonResult.OrderedAscending{
            let localNotification = UILocalNotification()
            localNotification.fireDate = dueDate
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            localNotification.alertBody = text
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.userInfo = ["itemID": itemID]
            
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            
            println("Scheduler notification \(localNotification) for itemID \(itemID)")
        }
    }
    
    deinit{
        let existingNotification = notificationForThisItem()
        if let notification = existingNotification{
            UIApplication.sharedApplication().cancelLocalNotification(notification)
            println("Removing an existing notification \(notification)")
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(text, forKey: "Text")
        aCoder.encodeBool(checked, forKey: "Checked")
        aCoder.encodeObject(dueDate, forKey: "DueDate")
        aCoder.encodeBool(shouldRemind, forKey: "ShouldRemind")
        aCoder.encodeInteger(itemID, forKey: "ItemID")
    }
    
    required init(coder aCoder: NSCoder){
        text = aCoder.decodeObjectForKey("Text") as! String
        checked = aCoder.decodeBoolForKey("Checked")
        dueDate = aCoder.decodeObjectForKey("DueDate") as! NSDate
        shouldRemind = aCoder.decodeBoolForKey("ShouldRemind")
        itemID = aCoder.decodeIntegerForKey("ItemID")
        super.init()
    }
    override init() {
        itemID = DataModel.nextChecklistItemID() // initialize the itemID
        super.init()
    }
}