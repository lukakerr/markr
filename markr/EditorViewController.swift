//
//  EditorViewController.swift
//  markr
//
//  Created by Luka Kerr on 9/10/17.
//  Copyright © 2017 Luka Kerr. All rights reserved.
//

import Cocoa
import Down

let DEFAULT_THEME = "Light"
let DEFAULT_FONT = "Monaco"
let DEFAULT_FONT_SIZE = "12"

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
    
    defaults.removeObject(forKey:"font")
    defaults.removeObject(forKey:"fontSize")
    
    let defaultFont = defaults.string(forKey: "font") ?? DEFAULT_FONT
    let defaultFontSize = defaults.string(forKey: "fontSize") ?? DEFAULT_FONT_SIZE
    editor.font = NSFont(name: defaultFont, size: CGFloat(Int(defaultFontSize)!))
  }
  
  @objc dynamic var editorText: String = "" {
    didSet {
      loadMarkdown()
    }
  }
  
  @objc private static let keyPathsForValuesAffectingAttributedTextInput: Set<String> = [
    #keyPath(editorText)
  ]
  
  @objc private var attributedTextInput: NSAttributedString {
    get { return NSAttributedString(string: self.editorText) }
    set { self.editorText = newValue.string }
  }
  
  func setFont(font: NSFont) {
    let defaultFont = defaults.string(forKey: "font") ?? DEFAULT_FONT
    let defaultFontSize = defaults.string(forKey: "fontSize") ?? DEFAULT_FONT_SIZE
  
    if (font.fontName != defaultFont) {
      defaults.setValue(font.fontName, forKey: "font")
    }
  
    if (font.pointSize != CGFloat(Int(defaultFontSize)!)) {
      defaults.setValue(font.pointSize, forKey: "fontSize")
    }
  }
  
  override func keyDown(with event: NSEvent) {
    switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
    case [.command] where event.characters == "s":
      print("cmd s")
    case [.command] where event.characters == "o":
      let dialog = NSOpenPanel()
      
      dialog.title = "Open a markdown file"
      dialog.allowedFileTypes = ["md"]
      dialog.allowsMultipleSelection = false
      dialog.canChooseDirectories = false
      
      if (dialog.runModal() == NSApplication.ModalResponse.OK) {
        let result = dialog.url
        
        if let result = result,
          let contents = try? String(contentsOf: result, encoding: .utf8) {
            editor.string = contents
        }
      }
    default:
      break
    }
    
    loadMarkdown()
  }
  
  func loadMarkdown() {
    let down = Down(markdownString: editor.string)
    
    if let font = editor.font {
      setFont(font: font)
    }
    
    if let attrMarkdown = try? down.toAttributedString(),
      let splitViewController = self.parent as? NSSplitViewController,
      let markdownSplitView = splitViewController.splitViewItems.last,
      let font = editor.font {
      let markdownVC = markdownSplitView.viewController as? MarkdownViewController
      markdownVC?.setMarkdown(markdownString: attrMarkdown, font: font)
    }
  }
  
  @IBAction func expandSidebar(_ sender: NSButton) {
    if let splitViewController = self.parent as? NSSplitViewController,
      let markdownSplitView = splitViewController.splitViewItems.last {
        markdownSplitView.collapseBehavior = .preferResizingSplitViewWithFixedSiblings
        markdownSplitView.animator().isCollapsed = !markdownSplitView.isCollapsed
    }
  }
    
}
