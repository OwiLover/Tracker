//
//  TrackerCreatorCell.swift
//  Tracker
//
//  Created by Owi Lover on 11/19/24.
//

import UIKit

final class TrackerCreatorCollectionCell: UICollectionViewCell {
    
    static let identifier = "TrackerCreationCellIdentifier"
    
    var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)        
        contentView.layer.cornerRadius = 8
        self.layer.cornerRadius = 16
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(text: String) {
        textLabel.text = text
    }
    
    private func setUI() {
        contentView.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: 40),
            contentView.widthAnchor.constraint(equalToConstant: 40),
            contentView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            textLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
