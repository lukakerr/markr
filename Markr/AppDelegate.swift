//
//  AppDelegate.swift
//  Markr
//
//  Created by Luka Kerr on 9/10/17.
//  Copyright © 2017 Luka Kerr. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Main window
    let window = NSApplication.shared.windows.first!
    
    window.appearance = NSAppearance(named: NSAppearance.Name.vibrantLight)
    
    // Title bar properties
    window.styleMask.insert(.fullSizeContentView)
    window.isOpaque = false
    window.invalidateShadow()
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
  
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
   return true
  }
  
  func application(_ sender: NSApplication, openFile filename: String) -> Bool {
    let window = NSApplication.shared.windows.first!
    if let editorViewController = window.contentViewController?.childViewControllers[0] as? EditorViewController {
      editorViewController.loadFile(filename)
    }
    return true
  }
  
  @IBAction func quit(_ sender: NSMenuItem) {
    NSApplication.shared.terminate(self)
  }
  
}

