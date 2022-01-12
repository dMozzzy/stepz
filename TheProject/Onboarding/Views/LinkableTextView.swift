//
//  LinkableTextView.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 31.07.21.
//

import UIKit


class LinkableTextView: UITextView {
    
    var handlers: [String: () -> Void] = [:]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isEditable = false
        isSelectable = true
        isScrollEnabled = false
        delegate = self
    }
    
    func setLink(_ link: String, handler: @escaping () -> Void) {
        handlers[link] = handler
        let text = NSMutableAttributedString(attributedString: attributedText)
        let range = text.mutableString.range(of: link)
        text.addAttribute(.link, value: link.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!, range: range)
        attributedText = text
    }

}

extension LinkableTextView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        handlers[URL.absoluteString.removingPercentEncoding!]?()
        return false
    }
    
    // to disable text selection
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedTextRange = nil
    }
}
