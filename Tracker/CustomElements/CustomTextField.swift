//
//  CustomTextField.swift
//  Tracker
//
//  Created by Owi Lover on 11/21/24.
//

import UIKit

final class CustomTextField: UITextField {
    
    let designedHeight: CGFloat = 75
    
    private var textInsets = UIEdgeInsets.zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .ypBackground
        self.clearButtonMode = .whileEditing
        
        self.layer.cornerRadius = 16
        let font = UIFont.systemFont(ofSize: 17, weight: .regular)
        self.font = font
        
//       К сожалению, в макете не совсем понятно, какой отступ справа, 41 или 62
        
        self.textInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 41)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let originalRect = super.clearButtonRect(forBounds: bounds)

        return originalRect.offsetBy(dx: -12, dy: 0)
    }
}

