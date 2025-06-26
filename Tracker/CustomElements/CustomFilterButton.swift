//
//  CustomFilterButton.swift
//  Tracker
//
//  Created by Owi Lover on 6/23/25.
//
import UIKit

class CustomFilterButton: UIButton {
    static let designedHeight: CGFloat = 50

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .ypBlue
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        
        self.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        self.setTitleColor(.ypWhiteConstant, for: .normal)
        
        self.contentEdgeInsets = .init(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        super.init(coder: coder)
    }
}
