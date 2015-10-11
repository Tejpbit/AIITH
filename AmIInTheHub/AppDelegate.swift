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
class AppDelegate: NSObject, NSApplicationDelegate, NSURLConnectionDataDelegate {
    
    @IBOutlet weak var statusMenu: NSMenu!
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)

    let formatter = NSDateComponentsFormatter()
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        statusItem.title = "asd"
        resultData = NSMutableData()
        formatter.unitsStyle = .Positional
        
        
        //refreshClock()
        
        //let myTimer = NSTimer(timeInterval: 2, target: self, selector: "refreshClock:", userInfo: nil, repeats: true)
        //NSRunLoop.currentRunLoop().addTimer(myTimer, forMode: NSRunLoopCommonModes)
        var helloWorldTimer = NSTimer.scheduledTimerWithTimeInterval(300.0, target: self, selector: "refreshClock", userInfo: nil, repeats: true)
    }
    
    func refreshClock() {
        let urlPath: String = "https://hubbit.chalmers.it/stats/andresa.json"
        let url: NSURL = NSURL(string: urlPath)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        let connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
        connection.start()
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        NSApplication.sharedApplication().terminate(self)
    }
    
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        exit(0)
    }
    
    private var resultData: NSMutableData!
    
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
                    
                    print(formatter.stringFromDateComponents(components))
                    statusItem.title = formatter.stringFromDateComponents(components)
                } else {
                    statusItem.title = "BadConvert"
                    print("BadConvert")
                }
            } else {
                statusItem.title = "NoDuration"
                print("NoDuration")
            }
            
        } catch  {
            
        }
        self.resultData.setData(NSData())
    }
}

