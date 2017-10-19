//
//  PreferencesWindowController.swift
//  Markr
//
//  Created by Luka Kerr on 11/10/17.
//  Copyright © 2017 Luka Kerr. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {
  
  let theme = defaults.string(forKey: "theme") ?? DEFAULT_THEME
  
  override func windowDidLoad() {
    super.windowDidLoad()

    // Window properties
    window?.titleVisibility = NSWindow.TitleVisibility.hidden;
    window?.titlebarAppearsTransparent = true;
    window?.styleMask.insert(.fullSizeContentView)
    window?.isOpaque = false
    window?.invalidateShadow()
    
    switch theme {
    case "Light":
      window?.appearance = NSAppearance(named: NSAppearance.Name.vibrantLight)
    default:
      window?.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
    }
    
  }

}
