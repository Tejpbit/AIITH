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
    @IBOutlet weak var intervalTextField: NSTextField!
    @IBOutlet weak var intervalSlider: NSSlider!
    
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    private var resultData: NSMutableData!
    let formatter = NSDateComponentsFormatter()
    let defaults = NSUserDefaults.standardUserDefaults()
    let CID_KEY = "CID"
    let INTERVAL_KEY = "INTERVAL"
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        defaults.registerDefaults([CID_KEY: "andresa", INTERVAL_KEY: 300])
        intervalSlider.maxValue = 3600
        intervalSlider.minValue = 300
        intervalSlider.doubleValue = defaults.doubleForKey(INTERVAL_KEY)
        intervalTextField.integerValue = intervalSlider.integerValue/60
        cidTextField.stringValue = defaults.stringForKey(CID_KEY)!
        
        optionsWindow.delegate = self
        optionsWindow.center()
        
        
        statusItem.title = "AIITH"
        statusItem.menu = statusMenu
        resultData = NSMutableData()
        formatter.unitsStyle = .Positional
        refreshClock()
        let updateinterval = defaults.doubleForKey(INTERVAL_KEY)
        NSTimer.scheduledTimerWithTimeInterval(updateinterval, target: self, selector: "refreshClock", userInfo: nil, repeats: true)
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
        defaults.setDouble(Double(intervalSlider.integerValue), forKey: INTERVAL_KEY)
        defaults.setObject(cidTextField.stringValue, forKey: CID_KEY)
        refreshClock()
    }

    @IBAction func configClicked(sender: NSMenuItem) {
        optionsWindow.makeKeyAndOrderFront(sender)
        optionsWindow.orderFrontRegardless()
    }
    
    @IBAction func sliderUpdate(sender: NSSlider) {
        intervalTextField.integerValue = sender.integerValue/60
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
            
        } catch  {
            statusItem.title = "CaughtError"
        }
        self.resultData.setData(NSData())
    }
}

