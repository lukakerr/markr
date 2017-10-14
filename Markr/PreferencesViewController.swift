//
//  PreferencesViewController.swift
//  Markr
//
//  Created by Luka Kerr on 11/10/17.
//  Copyright © 2017 Luka Kerr. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
  
  @IBOutlet weak var themeButton: NSSegmentedControl!
  
  let defaults = UserDefaults.standard

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let theme = defaults.string(forKey: "theme") ?? DEFAULT_THEME
    
    switch theme {
    case "Light":
      themeButton.selectedSegment = 0
    default:
      themeButton.selectedSegment = 1
    }
  }
  
  var wc = PreferencesWindowController()
  
  @IBAction func themeChanged(_ sender: NSSegmentedControl) {
    let theme = defaults.string(forKey: "theme") ?? DEFAULT_THEME
    var chosenTheme = theme
    
    if (sender.selectedSegment == 0) {
      // Light theme chosen
      chosenTheme = "Light"
      self.view.window?.appearance = NSAppearance(named: NSAppearance.Name.vibrantLight)
    } else {
      chosenTheme = "Dark"
      self.view.window?.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
    }
    wc.setWindowColor(theme: chosenTheme)
    
    NotificationCenter.default.post(
      name: NSNotification.Name(rawValue: "themeChangedNotification"),
      object: chosenTheme
    )
    
    defaults.setValue(chosenTheme, forKey: "theme")
  }
  
}
