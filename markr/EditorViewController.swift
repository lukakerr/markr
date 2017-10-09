//
//  EditorViewController.swift
//  markr
//
//  Created by Luka Kerr on 9/10/17.
//  Copyright © 2017 Luka Kerr. All rights reserved.
//

import Cocoa

let DEFAULT_THEME = "Light"
let DEFAULT_FONT = "Monaco"
let DEFAULT_FONT_SIZE = 15

class EditorViewController: NSViewController {

  @IBOutlet var editor: NSTextView!
  
  let defaults = UserDefaults.standard
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Register for keyDown events
    NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) -> NSEvent? in
      self.keyDown(with: event)
      return event
    }
    
    editor.font = NSFont(
      name: DEFAULT_FONT
      size: DEFAULT_FONT_SIZE
    )
  }
  
  @objc dynamic var editorText: String = "" {
    didSet {
      print(self.editorText)
    }
  }
  
  @objc private static let keyPathsForValuesAffectingAttributedTextInput: Set<String> = [
    #keyPath(editorText)
  ]
  
  @objc private var attributedTextInput: NSAttributedString {
    get { return NSAttributedString(string: self.editorText) }
    set { self.editorText = newValue.string }
  }
  
  override func keyDown(with event: NSEvent) {
    switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
    case [.command] where event.characters == "s":
      print("cmd s")
    default:
      break
    }
  }
  
  @IBAction func expandSidebar(_ sender: NSButton) {
    if let splitViewController = self.parent as? NSSplitViewController {
      let splitViewItem = splitViewController.splitViewItems
      
      splitViewItem.last!.collapseBehavior = .preferResizingSplitViewWithFixedSiblings
      splitViewItem.last!.animator().isCollapsed = !splitViewItem.last!.isCollapsed
    }
  }
    
}
