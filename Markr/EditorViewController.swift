//
//  EditorViewController.swift
//  Markr
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
  
  var editingFile = false
  var editingFilePath : URL?
  var fileChanged = false
  var editingNewFile = false
    
  var debouncedLoadMarkdown: Debouncer!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
    
    debouncedLoadMarkdown = Debouncer(delay: 0.3) {
        self.loadMarkdown()
    }
  }
  
  @objc dynamic var editorText: String = "" {
    didSet {
      debouncedLoadMarkdown.call()
      
      if editingFile {
        fileChanged = true
        if let path = editingFilePath {
          setFileLabel(path.lastPathComponent, fileChanged: fileChanged)
        }
      }
      
      if editingFilePath == nil && !editingFile {
        editingNewFile = true
        if (editor.string == "") {
          setFileLabel("", fileChanged: false)
        } else {
          setFileLabel("Untitled", fileChanged: editingNewFile)
        }
      }
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
  
    if font.fontName != defaultFont {
      defaults.setValue(font.fontName, forKey: "font")
    }
  
    if font.pointSize != CGFloat(Int(defaultFontSize)!) {
      defaults.setValue(font.pointSize, forKey: "fontSize")
    }
  }
  
  @IBAction func saveFile(_ sender: AnyObject?) {
    let contents = editor.string
    
    if editingFile && editingFilePath != nil {
      if let path = editingFilePath {
        // May want to remove all text so dont check if editorText is empty
        do {
          try contents.write(to: path, atomically: true, encoding: .utf8)
          fileChanged = false
          setFileLabel(path.lastPathComponent, fileChanged: fileChanged)
          return
        } catch {
          popup(message: "There was an error saving the file.")
        }
      }
    }

    saveDialog(nil, contents: contents)
  }
  
  @IBAction func saveDocumentAs(_ sender: AnyObject?) {
    let contents = editor.string
    if let path = editingFilePath {
      saveDialog(path, contents: contents)
    }
  }
  
  func saveDialog(_ path: URL?, contents: String) {
    let dialog = NSSavePanel()
    
    dialog.title = "Save a markdown file"
    dialog.allowedFileTypes = ["md"]
    dialog.canCreateDirectories = false
    
    if let path = editingFilePath {
      dialog.nameFieldStringValue = path.lastPathComponent
    }
    
    if dialog.runModal() == NSApplication.ModalResponse.OK {
      if let result = dialog.url {
        do {
          try contents.write(to: result, atomically: true, encoding: .utf8)
          editingFile = true
          editingFilePath = result
          fileChanged = false
          setFileLabel(result.lastPathComponent, fileChanged: fileChanged)
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
    
    if dialog.runModal() == NSApplication.ModalResponse.OK {
      if let result = dialog.url,
        let contents = try? String(contentsOf: result, encoding: .utf8) {
        editor.string = contents
        editingFile = true
        editingFilePath = result
        setFileLabel(result.lastPathComponent, fileChanged: fileChanged)
      }
    }
    loadMarkdown()
  }
  
  func loadFile(_ filePath: String) {
    if let content = try? String(contentsOfFile: filePath, encoding: .utf8) {
      editor.string = content
      editingFile = true
      
      let urlPath = NSURL.fileURL(withPath: filePath)
      editingFilePath = urlPath
      setFileLabel(urlPath.lastPathComponent, fileChanged: fileChanged)
    }
    loadMarkdown()
    MarkdownViewController().setWordCountLabel()
  }
  
  func loadMarkdown() {
    if let font = editor.font {
        setFont(font: font)
    }
    
    let string = editor.string
    
    DispatchQueue.global(qos: .userInitiated).async {
        if let splitViewController = self.parent as? NSSplitViewController,
            let markdownSplitView = splitViewController.splitViewItems.last {
            if let markdownVC = markdownSplitView.viewController as? MarkdownViewController {
                markdownVC.markdown.textStorage?.beginEditing()
                
                if let attrMarkdown = try? Down(markdownString: string).toAttributedString() {
                    DispatchQueue.main.async {
                        markdownVC.setMarkdown(attrMarkdown)
                    }
                }
            }
        }
    }
  }
  
  func setFileLabel(_ fileName: String, fileChanged: Bool) {
    if fileChanged {
      fileLabel.stringValue = fileName + " (edited)"
      return
    }
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
