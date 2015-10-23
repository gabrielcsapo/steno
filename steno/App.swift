//
//  App.swift
//  steno
//
//  Created by Csapo, Gabriel on 10/23/15.
//  Copyright © 2015 Csapo, Gabriel. All rights reserved.
//

import Foundation
import Cocoa

class App: NSObject {
    let configPath = NSHomeDirectory().stringByAppendingString("/.steno.json")
    var configData = NSData.init()
    var configModified = NSDate.init()
    var appDelegate : AppDelegate!
    
    func setup(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        parseConfig()
        
        let icon = NSImage(named: "statusIcon")
        icon?.template = true
        appDelegate.statusMenu.removeAllItems()
        appDelegate.statusItem.image = icon
        appDelegate.statusItem.menu = appDelegate.statusMenu
    
        let jsonObj = JSON(data: configData)
        if jsonObj != JSON.null {
            for key in jsonObj["groups"].arrayValue {
                let item = NSMenuItem.init(title: key["name"].stringValue, action:nil, keyEquivalent: key["name"].stringValue)
                let subMenu = NSMenu.init(title: "")
                for command in key["commands"].arrayValue {
                    let cItem = NSMenuItem.init(title: command["name"].stringValue, action:"commandClicked:", keyEquivalent: command["name"].stringValue)
                    cItem.representedObject = command.rawValue
                    subMenu.addItem(cItem)
                }
                appDelegate.statusMenu.setSubmenu(subMenu, forItem: item)
                appDelegate.statusMenu.addItem(item)
            }
        }
        
        appDelegate.statusMenu.addItem(NSMenuItem.separatorItem())
        appDelegate.statusMenu.addItem(NSMenuItem.init(title:"Edit Config", action:"editConfigClicked", keyEquivalent:"Edit"))
        appDelegate.statusMenu.addItem(NSMenuItem.init(title:"Quit", action:"quitClicked", keyEquivalent:"Quit"))
    }
    
    func update() {
        if configModified.compare(getModifiedTime(configPath)) == NSComparisonResult.OrderedAscending {
            setup(self.appDelegate)
        }
    }
    
    func parseConfig() {
        do {
            if NSFileManager.defaultManager().fileExistsAtPath(configPath) {
                configModified = getModifiedTime(configPath)
                print(configModified)
                configData = try
                    NSData(contentsOfURL: NSURL(fileURLWithPath: configPath), options: NSDataReadingOptions.DataReadingMappedIfSafe)
            } else {
                if let fileInResource = NSBundle.mainBundle().pathForResource("steno.default", ofType: "json") {
                    print(fileInResource)
                    print(configPath)
                    try NSFileManager.defaultManager().copyItemAtPath(fileInResource, toPath: configPath)
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func getModifiedTime(path: String) -> NSDate {
        do {
            let attributes = try NSFileManager.defaultManager().attributesOfItemAtPath(path)
            return attributes["NSFileModificationDate"]! as! NSDate
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return NSDate.init()
    }
    
    func runCommand(cmd : String, args : String...) -> (output: [String], error: [String], exitCode: Int32) {
        
        var output : [String] = []
        var error : [String] = []
        
        let task = NSTask()
        task.launchPath = cmd
        task.arguments = args
        
        let outpipe = NSPipe()
        task.standardOutput = outpipe
        let errpipe = NSPipe()
        task.standardError = errpipe
        
        task.launch()
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        print(outdata)
        if var string = String.fromCString(UnsafePointer(outdata.bytes)) {
            string = string.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
            output = string.componentsSeparatedByString("\n")
        }
        
        let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String.fromCString(UnsafePointer(errdata.bytes)) {
            string = string.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
            error = string.componentsSeparatedByString("\n")
        }
        
        task.waitUntilExit()
        let status = task.terminationStatus
        
        return (output, error, status)
    }
}