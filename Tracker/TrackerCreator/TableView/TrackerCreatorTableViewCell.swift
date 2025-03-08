//
//  TrackerCreatorTableViewCell.swift
//  Tracker
//
//  Created by Owi Lover on 11/21/24.
//

import UIKit

final class TrackerCreatorTableViewCell: UITableViewCell {
    static let identifier = "TrackerCreatorTableViewCell"
    
    private var savedBackgroundColor: UIColor? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        let font = UIFont.systemFont(ofSize: 17, weight: .regular)
        self.detailTextLabel?.font = font
        self.textLabel?.font = font
        
        self.tintColor = .ypBlue
        
        self.textLabel?.textColor = .ypBlack
        self.detailTextLabel?.textColor = .ypGray
        
        self.layer.masksToBounds = true

        self.layer.cornerRadius = 16
        
        self.backgroundColor = .ypBackground
        
        self.savedBackgroundColor = self.backgroundColor
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        self.layer.maskedCorners = []

    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted == true {
            savedBackgroundColor = self.backgroundColor
            self.changeBackgroundColor(color: .ypGray, animated: true)
        } else {
            self.changeBackgroundColor(color: savedBackgroundColor, animated: true)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected == true {
            savedBackgroundColor = self.backgroundColor
            self.changeBackgroundColor(color: .ypGray, animated: true)
        } else {
            self.changeBackgroundColor(color: savedBackgroundColor, animated: true)
        }
    }

    
    func setInsets(top: CGFloat, left: CGFloat, bottom: CGFloat , right: CGFloat) {
        let insets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        self.separatorInset = insets
    }
    
    func setAsLastCell() {
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    func setAsFirstCell() {
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func setAsTheOnlyCell() {
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    func changeBackgroundColor(color: UIColor?, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.1) { [weak self] in
                guard let self else { return }
                self.backgroundColor = color
            }
        } else {
            self.backgroundColor = color
        }
    }
}
