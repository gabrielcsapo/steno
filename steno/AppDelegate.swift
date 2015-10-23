//
//  AppDelegate.swift
//  steno
//
//  Created by Csapo, Gabriel on 10/22/15.
//  Copyright © 2015 Csapo, Gabriel. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)

    func quitClicked() {
        NSApplication.sharedApplication().terminate(self)
    }
    
    func userNotificationCenter (center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification){
        let alert = NSAlert()
        alert.messageText = notification.title!
        alert.informativeText = notification.informativeText!
        alert.runModal()
        NSUserNotificationCenter.defaultUserNotificationCenter().removeDeliveredNotification(notification)
    }
    
    @IBAction func commandClicked(sender: NSMenuItem) {
        if let command = sender.representedObject as? Dictionary<String, AnyObject> {
            let commandString = command["command"]! as! String
            let (output, error, status) = runCommand("/bin/sh", args: "-c", commandString)
            print(output)
            print(error)
            print(status)
            let notification = NSUserNotification.init()
            notification.title = commandString;
            notification.informativeText = output.description;
            notification.soundName = NSUserNotificationDefaultSoundName;
            
            NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification);
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {}
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        
        let icon = NSImage(named: "statusIcon")
        icon?.template = true
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        if let path = NSBundle.mainBundle().pathForResource("commands", ofType: "json") {
            do {
                let data = try
                    NSData(contentsOfURL: NSURL(fileURLWithPath: path), options: NSDataReadingOptions.DataReadingMappedIfSafe)
                let jsonObj = JSON(data: data)
                if jsonObj != JSON.null {
                    for key in jsonObj["groups"].arrayValue {
                        let item = NSMenuItem.init(title: key["name"].stringValue, action:nil, keyEquivalent: key["name"].stringValue)
                        let subMenu = NSMenu.init(title: "")
                        for command in key["commands"].arrayValue {
                            let cItem = NSMenuItem.init(title: command["name"].stringValue, action:"commandClicked:", keyEquivalent: command["name"].stringValue)
                            cItem.representedObject = command.rawValue
                            subMenu.addItem(cItem)
                        }
                        statusMenu.setSubmenu(subMenu, forItem: item)
                        statusMenu.addItem(item)
                    }
                } else {
                    print("could not get json from file, make sure that file contains valid json.")
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
        statusMenu.addItem(NSMenuItem.separatorItem())
        statusMenu.addItem(NSMenuItem.init(title:"Quit", action:"quitClicked", keyEquivalent:"Quit"))
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

