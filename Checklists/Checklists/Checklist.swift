//
//  Checklist.swift
//  Checklists
//
//  Created by 李金钊 on 15/3/8.
//  Copyright (c) 2015年 lijinzhao. All rights reserved.
//

import UIKit

class Checklist: NSObject, NSCoding{
    var name = ""
    var items = [ChecklistItem]()
    var iconName: String
    
    convenience init(name: String) {
        self.init(name: name, iconName: "No Icon")
    }
    
    init(name: String, iconName: String){
        self.name = name
        self.iconName = iconName
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "Name")
        aCoder.encodeObject(items, forKey: "Items")
        aCoder.encodeObject(iconName, forKey: "IconName")
    }
    
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("Name") as! String
        items = aDecoder.decodeObjectForKey("Items") as! [ChecklistItem]
        iconName = aDecoder.decodeObjectForKey("IconName") as! String
    }
    
    //what the fuck?
    func countUncheckedItems() -> Int{
        return reduce(items, 0){ cnt, item in cnt + (item.checked ? 0 : 1)}
    }
}
