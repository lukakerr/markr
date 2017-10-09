//
//  AppDelegate.swift
//  markr
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
    window.titleVisibility = NSWindow.TitleVisibility.hidden;
    window.titlebarAppearsTransparent = true;
    window.styleMask.insert(.fullSizeContentView)
    window.isOpaque = false
    window.invalidateShadow()
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }


}

