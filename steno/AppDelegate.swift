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
    
    func applicationWillTerminate(aNotification: NSNotification) {}
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        let app = App()
        app.setup(self)
    }
    
}

