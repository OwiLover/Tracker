//
//  StatsTableViewCell.swift
//  Tracker
//
//  Created by Owi Lover on 6/26/25.
//

import UIKit

class StatsTableViewCell: UITableViewCell {
    static let reuseIdentifier = "StatsTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        let fontForTextLabel = UIFont.systemFont(ofSize: 34, weight: .bold)
        let fontForDetailTextLabel = UIFont.systemFont(ofSize: 12, weight: .medium)
        self.detailTextLabel?.font = fontForDetailTextLabel
        self.textLabel?.font = fontForTextLabel
        
        self.textLabel?.textColor = .ypBlack
        self.detailTextLabel?.textColor = .ypBlack
        self.backgroundColor = .clear
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 16
        
        self.layer.borderWidth = 0

        setLabelsAnchors()
    }
    
    override func layoutSubviews() {
        self.gradientBorder(width: 1, colors: [.colorSelection1, .colorSelection9,.colorSelection3], andRoundCornersWithRadius: 16)
    }
    
    func setLabelsAnchors() {
        
        guard let textLabel, let detailTextLabel else { return }
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        detailTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            detailTextLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 7),
            detailTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            detailTextLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
