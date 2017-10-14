//
//  PreferencesWindowController.swift
//  Markr
//
//  Created by Luka Kerr on 11/10/17.
//  Copyright © 2017 Luka Kerr. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {
  
  let defaults = UserDefaults.standard
  
  override func windowDidLoad() {
    super.windowDidLoad()
    
    let theme = defaults.string(forKey: "theme") ?? DEFAULT_THEME
    
    if let window = window {
      setWindowColor(theme: theme)
      
      window.titleVisibility = NSWindow.TitleVisibility.hidden;
      window.titlebarAppearsTransparent = true;
      window.styleMask.insert(.fullSizeContentView)
      window.isOpaque = false
      window.invalidateShadow()
    }
    
  }
  
  func setWindowColor(theme: String) {
    if (theme == "Light") {
      window?.appearance = NSAppearance(named: NSAppearance.Name.vibrantLight)
    } else {
      window?.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
    }
  }

}
