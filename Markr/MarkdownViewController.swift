//
//  MarkdownViewController.swift
//  Markr
//
//  Created by Luka Kerr on 9/10/17.
//  Copyright © 2017 Luka Kerr. All rights reserved.
//

import Cocoa

class MarkdownViewController: NSViewController {

  @IBOutlet weak var markdownBackground: NSVisualEffectView!
  @IBOutlet weak var wordCountLabel: NSTextField!
  @IBOutlet var markdown: NSTextView! {
    didSet {
      markdown.layoutManager?.defaultAttachmentScaling = NSImageScaling.scaleProportionallyDown
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Register for theme change notification
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.setTheme),
      name: NSNotification.Name(rawValue: "themeChangedNotification"),
      object: nil
    )
    
    setTheme(nil)
  }
  
  @objc func setTheme(_ notification: Notification?) {
    var theme = notification?.object as? String ?? defaults.string(forKey: "theme")
    if theme == nil {
      theme = DEFAULT_THEME
    }
    
    if (theme == "Light") {
      self.view.window?.appearance = NSAppearance(named: NSAppearance.Name.vibrantLight)
      markdownBackground.material = .light
      markdown.textColor = NSColor.black
    } else {
      self.view.window?.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
      markdownBackground.material = .dark
      markdown.textColor = NSColor.white
    }
  }
  
  func setMarkdown(_ markdownString: NSAttributedString) {
    let formattedMarkdown = MarkdownFormatter().format(markdownString)
    markdown.textStorage?.mutableString.setString("")
    markdown.textStorage?.append(formattedMarkdown)
    setWordCountLabel()
  }
  
  func setWordCountLabel() {
    if let splitViewController = self.parent as? NSSplitViewController,
      let editorSplitView = splitViewController.splitViewItems.first {
        let editorViewController = editorSplitView.viewController as? EditorViewController
        if let charCount = editorViewController?.editor.textStorage?.words.count {
          if charCount == 1 {
            wordCountLabel.stringValue = String(charCount) + " word"
          } else if charCount > 0 {
            wordCountLabel.stringValue = String(charCount) + " words"
          } else {
            wordCountLabel.stringValue = ""
          }
        }
    }
  }

}
