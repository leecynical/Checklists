//
//  ItemDetailViewController.swift
//  Checklists
//
//  Created by 李金钊 on 15/3/5.
//  Copyright (c) 2015年 lijinzhao. All rights reserved.
//

import UIKit

protocol itemDetailViewControllerDelegate: class{
    func itemDetailViewControllerDidCancel(controller: ItemDetailViewController)
    func itemDetailViewController(controller: ItemDetailViewController,didFinishAddingItem item: ChecklistItem)
    func itemDetailViewController(controller: ItemDetailViewController,didFinishEditingItem item: ChecklistItem)
}

class ItemDetailViewController: UITableViewController,UITextFieldDelegate {

    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var dueDateLabel: UILabel!
    var itemToEdit: ChecklistItem?
    weak var delegate: itemDetailViewControllerDelegate?
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    var dueDate = NSDate()
    var datePickerVisible = false
    
    @IBAction func shouldRemindToggled(switchControl: UISwitch){
        textField.resignFirstResponder()
        
        if switchControl.on {
            let notificationSettings = UIUserNotificationSettings(forTypes: .Alert | .Sound, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        }
    }
    
    func showDatePicker(){
        datePickerVisible = true
        
        let indexPathDateNow = NSIndexPath(forRow: 1, inSection: 1)
        let indexPathDatePicker = NSIndexPath(forRow: 2, inSection: 1)
        
        if let dateCell = tableView.cellForRowAtIndexPath(indexPathDateNow){
            dateCell.detailTextLabel!.textColor = dateCell.detailTextLabel!.tintColor
        }
        
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: .Fade)
        tableView.reloadRowsAtIndexPaths([indexPathDateNow], withRowAnimation: .None)
        tableView.endUpdates()
        
        if let pickerCell = tableView.cellForRowAtIndexPath(indexPathDatePicker){
            let datePicker = pickerCell.viewWithTag(100) as! UIDatePicker
            datePicker.setDate(dueDate, animated: true)
        }
    }
    
    func hideDatePicker(){
        if datePickerVisible{
            datePickerVisible = false
            let indexPathDateNow = NSIndexPath(forRow: 1, inSection: 1)
            let indexPathDatePicker = NSIndexPath(forRow: 2, inSection: 1)
            if let dateCell = tableView.cellForRowAtIndexPath(indexPathDateNow){
                dateCell.detailTextLabel!.textColor = UIColor(white: 0, alpha: 0.5)
            }
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: .Fade)
            tableView.reloadRowsAtIndexPaths([indexPathDateNow], withRowAnimation: .None)
            tableView.endUpdates()

        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        hideDatePicker()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 1 && indexPath.row == 2{
            var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("DatePickerCell") as? UITableViewCell
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: "DatePickerCell")
                cell.selectionStyle = .None
                
                let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 320, height: 216))
                datePicker.tag = 100
                cell.contentView.addSubview(datePicker)
                
                datePicker.addTarget(self, action: Selector("dateChanged:"), forControlEvents: .ValueChanged)
                }
                return cell
            }else{
                return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
            }
    }
    
    func dateChanged(datePicker: UIDatePicker){
        dueDate = datePicker.date
        updateDueDateLabel()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && datePickerVisible {
            return 3
        }else{
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 2{
            return 217 //for a separator line
        }else{
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        textField.resignFirstResponder()
        
        if indexPath.section == 1 && indexPath.row == 1{
            if !datePickerVisible{
                showDatePicker()
            }else{
                hideDatePicker()
            }
        }
    }
    
    @IBAction func done(){
        if let item = itemToEdit{
            item.text = textField.text
            item.shouldRemind = shouldRemindSwitch.on
            item.dueDate = dueDate
            item.scheduleNotification()
            delegate?.itemDetailViewController(self, didFinishEditingItem: item)
        }else{
            let item = ChecklistItem()
            item.text = textField.text
            item.checked = false
            item.shouldRemind = shouldRemindSwitch.on
            item.dueDate = dueDate
            item.scheduleNotification()
            delegate?.itemDetailViewController(self, didFinishAddingItem: item)
        }
    }
    @IBAction func cancel(){
        delegate?.itemDetailViewControllerDidCancel(self)
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 1 && indexPath.row == 1{
            return indexPath
        }else{
            return nil
        }
    }
    
    //override the following method?
    override func tableView(tableView: UITableView, var indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        if indexPath.section == 1 && indexPath.row == 2{
            indexPath = NSIndexPath(forRow: 0, inSection: indexPath.section)
        }
        return super.tableView(tableView , indentationLevelForRowAtIndexPath: indexPath)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let oldText: NSString = textField.text
        let newText: NSString = oldText.stringByReplacingCharactersInRange(range, withString: string)
        doneBarButton.enabled = (newText.length > 0)
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        textField.becomeFirstResponder()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 44
        
        if let item = itemToEdit{
            title = "Edit Item"
            textField.text = item.text
            doneBarButton.enabled = true
            shouldRemindSwitch.on = item.shouldRemind
            dueDate = item.dueDate
        }
        updateDueDateLabel()
    }
    
    func updateDueDateLabel(){
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        dueDateLabel.text = formatter.stringFromDate(dueDate)
    }
    
}
