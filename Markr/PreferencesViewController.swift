//
//  PreferencesViewController.swift
//  Markr
//
//  Created by Luka Kerr on 11/10/17.
//  Copyright © 2017 Luka Kerr. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
  
  var theme = defaults.string(forKey: "theme") ?? DEFAULT_THEME {
    didSet {
      defaults.setValue(theme, forKey: "theme")
    }
  }
  
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
  
  @IBAction func themeChanged(_ sender: NSSegmentedControl) {
    if (sender.selectedSegment == 0) {
      theme = "Light"
      self.view.window?.appearance = NSAppearance(named: NSAppearance.Name.vibrantLight)
    } else {
      theme = "Dark"
      self.view.window?.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
    }
    
    NotificationCenter.default.post(
      name: NSNotification.Name(rawValue: "themeChangedNotification"),
      object: theme
    )
  }
  
}
