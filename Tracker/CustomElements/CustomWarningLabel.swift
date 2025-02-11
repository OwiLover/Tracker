//
//  CustomWarningLabel.swift
//  Tracker
//
//  Created by Owi Lover on 11/28/24.
//

import UIKit

final class CustomWarningLabel: UILabel {
    
    private var warningLabelConstraints: [NSLayoutConstraint] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        self.textColor = .ypRed
        self.textAlignment = .center
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addConstraints(_ constraints: [NSLayoutConstraint]) {
        super.addConstraints(constraints)
        self.warningLabelConstraints.append(contentsOf: constraints)
    }
    
}
