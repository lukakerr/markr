//
//  MarkdownFormatter.swift
//  Markr
//
//  Created by Luka Kerr on 14/10/17.
//  Copyright © 2017 Luka Kerr. All rights reserved.
//

import Foundation
import Cocoa

class MarkdownFormatter {
  
  let defaults = UserDefaults.standard
  
  func format(_ markdownString: NSAttributedString) -> NSAttributedString {
    var attrStr = NSMutableAttributedString(attributedString: markdownString)
    
    attrStr = changeFont(attrStr)
    attrStr = centerImages(attrStr)
    
    return attrStr
  }
  
  func changeFont(_ attrStr: NSMutableAttributedString) -> NSMutableAttributedString {
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
        } else {
          paragraphStyle.paragraphSpacing = 7.5
        }
        
        attrStr.addAttribute(
          NSAttributedStringKey.paragraphStyle,
          value: paragraphStyle,
          range: range
        )
      }
    }
    return attrStr
  }
  
  func centerImages(_ attrStr: NSMutableAttributedString) -> NSMutableAttributedString {
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
    return attrStr
  }
  
}
