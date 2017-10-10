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
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func setMarkdown(markdownString: NSAttributedString, font: NSFont) {
    let newAttributedString = NSMutableAttributedString(attributedString: markdownString)

    // Enumerate through all the font ranges
    newAttributedString.enumerateAttribute(NSAttributedStringKey.font, in: NSMakeRange(0, newAttributedString.length), options: []) { value, range, stop in
      guard var currentFont = value as? NSFont else {
        return
      }
      
      let fontName: String = currentFont.fontName.lowercased()
      var destinationFont: NSFont = NSFont(name: "Helvetica", size: currentFont.pointSize)!
      
      if fontName.range(of: "bold") != nil {
        if let font = NSFont(name: "Helvetica Bold", size: currentFont.pointSize) {
          destinationFont = font
        }
      } else if fontName.range(of: "italic") != nil {
        if let font = NSFont(name: "Helvetica Oblique", size: currentFont.pointSize) {
          destinationFont = font
        }
      } else if fontName.range(of: "courier") != nil {
        if let font = NSFont(name: "Monaco", size: currentFont.pointSize),
          let newCurrentFont = NSFont(name: currentFont.fontName, size: currentFont.pointSize * 0.85) {
            destinationFont = font
            currentFont = newCurrentFont
        }
      }

      // An NSFontDescriptor describes the attributes of a font: family name, face name, point size, etc.
      // Here we describe the replacement font as coming from the "Hoefler Text" family
      let fontDescriptor = destinationFont.fontDescriptor

      // Ask the OS for an actual font that most closely matches the description above
      if let newFontDescriptor = fontDescriptor.matchingFontDescriptors(withMandatoryKeys: [NSFontDescriptor.AttributeName.name]).first {
        if let newFont = NSFont(descriptor: newFontDescriptor, size: currentFont.pointSize * 1.25) {
          newAttributedString.addAttributes([NSAttributedStringKey.font: newFont], range: range)
        }
      }
    }

    markdown.textStorage?.mutableString.setString("")
    markdown.textStorage?.append(newAttributedString)
  }
}
