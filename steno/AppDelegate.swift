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
        app.runCommand("/bin/sh", args: "-c", command)
    }
    
    @IBAction func commandClicked(sender: NSMenuItem) {
        if let command = sender.representedObject as? Dictionary<String, AnyObject> {
            let commandString = command["command"]! as! String
            let (output, error, status) = app.runCommand("/bin/sh", args: "-c", commandString)
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
    
    func menuWillOpen(menu: NSMenu) {
        app.update()
    }
    
    func userNotificationCenter (center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification){
        let alert = NSAlert()
        alert.messageText = notification.title!
        alert.informativeText = notification.informativeText!
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

