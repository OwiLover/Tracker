//
//  TrackerCreatorCollectionHeader.swift
//  Tracker
//
//  Created by Owi Lover on 11/20/24.
//

import UIKit

final class CustomCollectionHeader: UICollectionReusableView {
    static let identifier = "CustomCollectionHeaderIdentifier"
    
    static let fontSize: CGFloat = 19
    
    private var header: UILabel = {
        let header = UILabel()
        header.font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        return header
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        super.init(coder: coder)
    }
    
    func setHeader(title: String) {
        header.text = title
    }
    
    private func setUI() {
        addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            header.topAnchor.constraint(equalTo: topAnchor),
            header.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
