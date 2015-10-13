//
//  AppDelegate.swift
//  AmIInTheHub
//
//  Created by André Samuelsson on 10/10/15.
//  Copyright © 2015 André Samuelsson. All rights reserved.
//

import Cocoa
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, NSURLConnectionDataDelegate {
    @IBOutlet weak var optionsWindow: NSWindow!
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var cidTextField: NSTextField!
    
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    private var resultData: NSMutableData!
    let formatter = NSDateComponentsFormatter()
    let defaults = NSUserDefaults.standardUserDefaults()
    let CID_KEY = "CID"
    let FIRST_START_KEY = "FIRST_START"
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        defaults.registerDefaults([CID_KEY: "", FIRST_START_KEY: true])
        cidTextField.stringValue = defaults.stringForKey(CID_KEY)!
        
        optionsWindow.delegate = self
        optionsWindow.center()
        
        
        statusItem.title = "AIITH"
        statusItem.menu = statusMenu
        resultData = NSMutableData()
        formatter.unitsStyle = .Positional
        refreshClock()
        NSTimer.scheduledTimerWithTimeInterval(300, target: self, selector: "refreshClock", userInfo: nil, repeats: true)
        
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
        
        if defaults.boolForKey(FIRST_START_KEY) {
            openConfigWindow()
            defaults.setBool(false, forKey: FIRST_START_KEY)
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    func refreshClock() {
        if let cid = defaults.stringForKey(CID_KEY) {
            let urlPath: String = "https://hubbit.chalmers.it/stats/\(cid).json"
            let url: NSURL = NSURL(string: urlPath)!
            let request: NSURLRequest = NSURLRequest(URL: url)
            let connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
            connection.start()
        }
    }
    
    func windowWillClose(notification: NSNotification) {
        defaults.setObject(cidTextField.stringValue, forKey: CID_KEY)
        refreshClock()
    }

    @IBAction func configClicked(sender: NSMenuItem) {
        openConfigWindow()
    }
    
    func openConfigWindow() {
        optionsWindow.makeKeyAndOrderFront(nil)
        //optionsWindow.orderFrontRegardless()
        optionsWindow.orderFront(nil)
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.resultData.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        do {
            let jsonResult = try NSJSONSerialization.JSONObjectWithData(resultData!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            
            if let lastSession = jsonResult["last_session"] {
                if let lastSessionString = lastSession as? String {
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'.000+02:00'"
                    
                    let date = dateFormatter.dateFromString(lastSessionString)
                    
                    let currentDate = NSDate()
                    if currentDate.compare(date!) == .OrderedAscending {
                        displayLastSessionTime(jsonResult)
                    } else {
                        
                        displayTimeSinceLastSession(date!)

                    }
                }
            }
            
            
            
            
            
        } catch  {
            statusItem.title = "CaughtError"
        }
        self.resultData.setData(NSData())
    }
    
    func displayLastSessionTime(jsonResult: NSDictionary) {
        if let duration = jsonResult["last_session_duration"] {
            if let time = duration as? Int {
                
                
                let components = NSDateComponents()
                components.hour = 0
                components.minute = time/60
                
                statusItem.title = formatter.stringFromDateComponents(components)
            } else {
                statusItem.title = "BadConvertToInt"
            }
        } else {
            statusItem.title = "NoDurationInJson"
        }
    }
    
    func displayTimeSinceLastSession(lastSession: NSDate) {
        let format = NSDateFormatter()
        format.dateFormat = "'Last: 'HH:mm"
        statusItem.title = format.stringFromDate(lastSession)
    }
}

