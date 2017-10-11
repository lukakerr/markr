//
//  MarkdownViewController.swift
//  markr
//
//  Created by Luka Kerr on 9/10/17.
//  Copyright © 2017 Luka Kerr. All rights reserved.
//

import Cocoa

class MarkdownViewController: NSViewController {

  @IBOutlet var markdown: NSTextView!
  @IBOutlet weak var markdownBackground: NSVisualEffectView!
  
  let defaults = UserDefaults.standard
  
  override func viewDidLoad() {
    super.viewDidLoad()
    markdown.layoutManager?.defaultAttachmentScaling = NSImageScaling.scaleProportionallyDown
    
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
    if let theme = theme {
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
  }
  
  func setMarkdown(markdownString: NSAttributedString) {
    let attrStr = NSMutableAttributedString(attributedString: markdownString)
    
    // Enumerate through all the font ranges
    attrStr.enumerateAttribute(NSAttributedStringKey.font, in: NSMakeRange(0, attrStr.length), options: []) { value, range, stop in
      guard var currentFont = value as? NSFont else {
        return
      }
      
      let theme = defaults.string(forKey: "theme") ?? DEFAULT_THEME
      
      let fontName: String = currentFont.fontName.lowercased()
      
      var destinationFont: NSFont = NSFont(name: "Helvetica Light", size: currentFont.pointSize)!
      
      let boldFont = fontName.range(of: "bold")
      let italicFont = fontName.range(of: "italic")
      let codeFont = fontName.range(of: "courier")
      
      if boldFont != nil {
        if let font = NSFont(name: "Helvetica Bold", size: currentFont.pointSize) {
          destinationFont = font
        }
      } else if italicFont != nil {
        if let font = NSFont(name: "Helvetica Oblique", size: currentFont.pointSize) {
          destinationFont = font
        }
      } else if codeFont != nil {
        if let font = NSFont(name: "Monaco", size: currentFont.pointSize),
          let newCurrentFont = NSFont(name: currentFont.fontName, size: currentFont.pointSize * 0.85) {
            destinationFont = font
            currentFont = newCurrentFont
        }
      }

      let fontDescriptor = destinationFont.fontDescriptor

      // Ask the system for an actual font that most closely matches the description above
      if let newFontDescriptor = fontDescriptor.matchingFontDescriptors(withMandatoryKeys: [NSFontDescriptor.AttributeName.name]).first,
        let newFont = NSFont(descriptor: newFontDescriptor, size: currentFont.pointSize * 1.25) {
          attrStr.addAttributes([NSAttributedStringKey.font: newFont], range: range)
        
          if (theme == "Light" && !(codeFont != nil)) {
            attrStr.addAttribute(
              NSAttributedStringKey.foregroundColor,
              value: NSColor.black,
              range: range
            )
          } else if (!(codeFont != nil)) {
            attrStr.addAttribute(
              NSAttributedStringKey.foregroundColor,
              value: NSColor.white,
              range: range
            )
          }
        
          if codeFont != nil {
            if (theme == "Light") {
              attrStr.addAttribute(
                NSAttributedStringKey.foregroundColor,
                value: NSColor(red:0, green:0, blue:0, alpha:0.5),
                range: range
              )
            } else {
              attrStr.addAttribute(
                NSAttributedStringKey.foregroundColor,
                value: NSColor(red:1, green:1, blue:1, alpha:0.75),
                range: range
              )
            }
          }
        
          let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
          paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 15, options: NSDictionary() as! [NSTextTab.OptionKey : Any])]
          paragraphStyle.defaultTabInterval = 15
          paragraphStyle.firstLineHeadIndent = 0
          paragraphStyle.headIndent = 0
          if (!(codeFont != nil)) {
            paragraphStyle.paragraphSpacing = 15
          }
        
          attrStr.addAttribute(
            NSAttributedStringKey.paragraphStyle,
            value: paragraphStyle,
            range: range
          )
      }
    }
    
    // Enumerate over images in attributed string and center them
    attrStr.enumerateAttribute(NSAttributedStringKey.attachment, in: NSMakeRange(0, attrStr.length), options: []) { value, range, stop in
      if (value as? NSTextAttachment) != nil {
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        attrStr.addAttribute(
          NSAttributedStringKey.paragraphStyle,
          value: paragraphStyle,
          range: NSRange(location: range.location, length: range.length)
        )
      }
    }
    
    markdown.textStorage?.mutableString.setString("")
    markdown.textStorage?.append(attrStr)
  }

}
