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
let DEFAULT_FONT_SIZE = "14"

class EditorViewController: NSViewController {

  @IBOutlet var editor: NSTextView!
  @IBOutlet weak var editorBackground: NSVisualEffectView!
  @IBOutlet weak var fileLabel: NSTextField!
  
  let defaults = UserDefaults.standard
  var editingFile = false
  var editingFilePath : URL?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Register for keyDown events
    NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) -> NSEvent? in
      self.keyDown(with: event)
      return event
    }
    
    // Register for theme change notification
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.setTheme),
      name: NSNotification.Name(rawValue: "themeChangedNotification"),
      object: nil
    )
    
    editor.insertionPointColor = NSColor(red:0.75, green:0.75, blue:0.75, alpha:1.00)
    
    let defaultFont = defaults.string(forKey: "font") ?? DEFAULT_FONT
    let defaultFontSize = defaults.string(forKey: "fontSize") ?? DEFAULT_FONT_SIZE
    editor.font = NSFont(name: defaultFont, size: CGFloat(Int(defaultFontSize)!))
    
    setTheme(nil)
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
  
  @objc func setTheme(_ notification: Notification?) {
    var theme = notification?.object as? String ?? defaults.string(forKey: "theme")
    if theme == nil {
      theme = DEFAULT_THEME
    }
    if let theme = theme {
      if (theme == "Light") {
        self.view.window?.appearance = NSAppearance(named: NSAppearance.Name.vibrantLight)
        editorBackground.material = .light
        editor.textColor = NSColor.black
      } else {
        self.view.window?.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        editorBackground.material = .dark
        editor.textColor = NSColor.white
      }
    }
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
    loadMarkdown()
  }
  
  @IBAction func saveFile(_ sender: AnyObject?) {
    let contents = editor.string
    
    if (editingFile && editingFilePath != nil) {
      if let path = editingFilePath {
        // May want to remove all text so dont check if editorText is empty
        do {
          try contents.write(to: path, atomically: true, encoding: String.Encoding.utf8)
          return
        } catch {
          popup(message: "There was an error saving the file.")
        }
      }
    }

    let dialog = NSSavePanel()
    
    dialog.title = "Save a markdown file"
    dialog.allowedFileTypes = ["md"]
    dialog.canCreateDirectories = false
    
    if (dialog.runModal() == NSApplication.ModalResponse.OK) {
      if let result = dialog.url {
        do {
          try contents.write(to: result, atomically: true, encoding: String.Encoding.utf8)
          editingFile = true
          editingFilePath = result
          setFileLabel(result.lastPathComponent)
        } catch {
          self.popup(message: "There was an error saving the file.")
        }
      }
    }
  }
  
  @IBAction func openFile(_ sender: AnyObject?) {
    let dialog = NSOpenPanel()
    
    dialog.title = "Open a markdown file"
    dialog.allowedFileTypes = ["md"]
    dialog.allowsMultipleSelection = false
    dialog.canChooseDirectories = false
    
    if (dialog.runModal() == NSApplication.ModalResponse.OK) {
      if let result = dialog.url,
        let contents = try? String(contentsOf: result, encoding: .utf8) {
        editor.string = contents
        editingFile = true
        editingFilePath = result
        setFileLabel(result.lastPathComponent)
      }
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
      let markdownSplitView = splitViewController.splitViewItems.last {
      let markdownVC = markdownSplitView.viewController as? MarkdownViewController
        markdownVC?.setMarkdown(markdownString: attrMarkdown)
    }
  }
  
  func setFileLabel(_ fileName: String) {
    fileLabel.stringValue = fileName
  }
  
  func popup(message: String) {
    let alert = NSAlert()
    alert.informativeText = message
    alert.alertStyle = .warning
    alert.addButton(withTitle: "OK")
    alert.runModal()
  }
  
  @IBAction func expandSidebar(_ sender: NSButton) {
    if let splitViewController = self.parent as? NSSplitViewController,
      let markdownSplitView = splitViewController.splitViewItems.last {
        markdownSplitView.collapseBehavior = .preferResizingSplitViewWithFixedSiblings
        markdownSplitView.animator().isCollapsed = !markdownSplitView.isCollapsed
    }
  }
    
}
