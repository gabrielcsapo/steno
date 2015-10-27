//
//  AppDelegate.swift
//  steno
//
//  Created by Csapo, Gabriel on 10/22/15.
//  Copyright © 2015 Csapo, Gabriel. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, NSUserNotificationCenterDelegate {

    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    let app = App()
    
    func quitClicked() {
        NSApplication.sharedApplication().terminate(self)
    }
    
    func editConfigClicked() {
        let command = "open " + app.configPath
        app.runCommand("/bin/sh", type:"async", args: "-c", command)
    }
    
    @IBAction func commandClicked(sender: NSMenuItem) {
        if let command = sender.representedObject as? Dictionary<String, AnyObject> {
            var commandString = command["command"]! as! String
            let typeString = command["type"] as! String
            let (output, error, status) = app.runCommand("/bin/sh", type:typeString, args: "-c", commandString)
            print(output)
            print(error)
            print(status)
            
            var args = Dictionary<String, AnyObject>()
            
            if(command["args"] !== nil) {
                for key in (command["args"] as? Dictionary<String, AnyObject>)!{
                    let alert = NSAlert()
                    alert.messageText = key.1 as! String
                    alert.addButtonWithTitle("Ok")
                    alert.addButtonWithTitle("Cancel")
                    let input = NSTextField.init(frame: NSMakeRect(0, 0, 200, 24))
                    input.stringValue = ""
                    alert.accessoryView = input;
                    let button = alert.runModal()

                    if (button == NSAlertFirstButtonReturn) {
                        args[key.0] = input.stringValue
                    } else if (button == NSAlertSecondButtonReturn) {
                        args[key.0] = ""
                    }
                }
                for key in (args) {
                    let needle = "{" + key.0 + "}"
                    commandString = commandString.stringByReplacingOccurrencesOfString(needle, withString: key.1 as! String)
                }
            }
            
            if(typeString == "async") {
                let notification = NSUserNotification.init()
                notification.title = commandString;
                notification.subtitle = error.description
                notification.informativeText = output.description
                notification.soundName = NSUserNotificationDefaultSoundName
                
                NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
            }
        }
    }
    
    func menuWillOpen(menu: NSMenu) {
        app.update()
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
    
    func userNotificationCenter (center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification){
        var content = notification.subtitle
        content?.appendContentsOf("\n")
        content?.appendContentsOf(notification.informativeText!)
        let alert = NSAlert()
        alert.messageText = notification.title!
        alert.informativeText = content!
        alert.runModal()
        NSUserNotificationCenter.defaultUserNotificationCenter().removeDeliveredNotification(notification)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {}
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        statusMenu.delegate = self
        app.setup(self)
    }
    
}

