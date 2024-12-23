//
//  CustomButton.swift
//  Tracker
//
//  Created by Owi Lover on 11/8/24.
//

import UIKit

final class CustomButton: UIButton {
    
    let designedHeight: CGFloat = 60

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setTitleColor(.ypWhite, for: .normal)
        self.setTitleColor(.ypWhiteConstant, for: .disabled)
//        self.color
        
        self.backgroundColor = .ypBlack
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isEnabled: Bool {
        didSet {
            UIView.animate(withDuration: 0.25) {
                self.backgroundColor = self.isEnabled ? .ypBlack : .ypGray
            }
        }
    }
    
}
