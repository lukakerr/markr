//
//  PreferencesViewController.swift
//  Markr
//
//  Created by Luka Kerr on 11/10/17.
//  Copyright © 2017 Luka Kerr. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
  
  let theme = UserDefaults.standard.string(forKey: "theme") ?? DEFAULT_THEME
  
  @IBOutlet weak var themeButton: NSSegmentedControl! {
    didSet {
      switch theme {
      case "Light":
        themeButton.selectedSegment = 0
      default:
        themeButton.selectedSegment = 1
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  var wc = PreferencesWindowController()
  
  @IBAction func themeChanged(_ sender: NSSegmentedControl) {
    var chosenTheme = theme
    
    if (sender.selectedSegment == 0) {
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
    
    UserDefaults.standard.setValue(chosenTheme, forKey: "theme")
  }
  
}
