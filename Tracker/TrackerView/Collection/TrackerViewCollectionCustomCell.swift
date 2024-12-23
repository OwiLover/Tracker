//
//  TrackerViewCollectionCustomCell.swift
//  Tracker
//
//  Created by Owi Lover on 12/2/24.
//

import UIKit

final class TrackerViewCollectionCustomCell: UICollectionViewCell {
    
    static let identifier = "TrackerViewCellIdentifier"
    
    static var designedHeight: CGFloat {
        designedStreakViewHeight + designedTrackerCardHeight
    }
    
    static let designedTrackerCardHeight: CGFloat = 90
    
    static let designedStreakViewHeight: CGFloat = 58
    
    private let spacing: UIEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    
    private let elementSpacing: CGFloat = 8
    
    private var streakCount: UInt16 = 0
    
    private var id: UInt32?

    weak var delegate: TrackerViewCollectionCustomCellDelegate?
    
//    MARK: Если выставить всё в соответсвии с макетом, то получается две несостыковки:
//    1) Смайлик при размере шрифта 16 становится слишком большим и едва помещается в view размером 24 на 24 пикселя (аналогичная ситуация, если закруглить frame текстового лейбла, хранящего смайлик
//    2) Закругление View для смайлика слишком большое, было подставлено значение, подходящее визуально
//    В связи с этим у меня вопрос, что следует сделать? Уменьшение шрифта для смайлика сделает его слишком маленьким, возможно стоит увеличить размер View?
    
    private let trackerCardView: UIView = {
        let view = UIView()
        
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.ypGray.withAlphaComponent(0.3).cgColor
        
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let emojiLabelView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .ypWhiteConstant.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private let trackerNameLabel: UILabel = {
        let label = UILabel()
        
        let font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.font = font
        label.numberOfLines = 2
        label.textColor = .ypWhiteConstant
        
        let desiredLineHeight = 18.0
        let originalLineHeight = font.lineHeight
        let spacingValue = desiredLineHeight - originalLineHeight
        
        return label
    }()
    
    private let trackerNameView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private let streakView: UIView = {
        let view = UIView()

        return view
    }()
    
    private let streakLabel: UILabel = {
        let label = UILabel()
        let font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        label.font = font
        
        label.textColor = .ypBlack
        
        return label
    }()
    
    private let streakButton: UIButton = {
        let button = UIButton()
        let plusImage = UIImage(systemName: "plus")
        
        button.setImage(plusImage, for: .normal)
        button.tintColor = .ypWhite
        
        let checkImage = UIImage(systemName: "checkmark")
        
        button.setImage(checkImage, for: .selected)
        
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true

        button.addTarget(nil, action: #selector(streakButtonWasPressed), for: .touchUpInside)
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setTrackerCard()
        setStreakView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        id = nil
        streakCount = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(id: UInt32, emoji: String, name: String, backgroundColor: UIColor, streakCount: UInt16 = 0, delegate: TrackerViewCollectionCustomCellDelegate? = nil, isEnabled: Bool, isSelected: Bool = false) {
        self.id = id
        emojiLabel.text = emoji
        trackerNameLabel.text = name
        trackerCardView.backgroundColor = backgroundColor
        self.streakCount = streakCount
        
        streakButton.backgroundColor = isEnabled && !isSelected ? backgroundColor : backgroundColor.withAlphaComponent(0.3)
        
        streakLabel.text = "\(streakCount) \(getDayCountString(number: streakCount))"
        
        streakButton.isEnabled = isEnabled
        
        streakButton.isSelected = isSelected
        
        self.delegate = delegate
    }
    
    private func setStreakButtonAction(action: Selector) {
        streakButton.addTarget(nil, action: action, for: .touchUpInside)
    }
    
    private func setTrackerCard() {
        
        emojiLabelView.addSubview(emojiLabel)
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        trackerNameView.addSubview(trackerNameLabel)
        
        trackerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        trackerCardView.addSubview(emojiLabelView)
        
        trackerCardView.addSubview(trackerNameView)
        
        trackerNameView.translatesAutoresizingMaskIntoConstraints = false
        
        emojiLabelView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(trackerCardView)
        
        trackerCardView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            trackerCardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerCardView.heightAnchor.constraint(equalToConstant: TrackerViewCollectionCustomCell.designedTrackerCardHeight),
            
            emojiLabelView.topAnchor.constraint(equalTo: trackerCardView.topAnchor, constant: spacing.top),
            emojiLabelView.leadingAnchor.constraint(equalTo: trackerCardView.leadingAnchor, constant: spacing.left),

            emojiLabelView.heightAnchor.constraint(equalToConstant: 24),
            emojiLabelView.widthAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerYAnchor.constraint(equalTo: emojiLabelView.centerYAnchor),
            emojiLabel.centerXAnchor.constraint(equalTo: emojiLabelView.centerXAnchor),
            
            trackerNameView.topAnchor.constraint(equalTo: emojiLabelView.bottomAnchor, constant: elementSpacing),
            trackerNameView.leadingAnchor.constraint(equalTo: trackerCardView.leadingAnchor, constant: spacing.left),
            trackerNameView.trailingAnchor.constraint(equalTo: trackerCardView.trailingAnchor, constant: -spacing.right),
            trackerNameView.bottomAnchor.constraint(equalTo: trackerCardView.bottomAnchor, constant: -spacing.bottom),
            
            trackerNameLabel.bottomAnchor.constraint(equalTo: trackerNameView.bottomAnchor),
            trackerNameLabel.leadingAnchor.constraint(equalTo: trackerNameView.leadingAnchor),
            trackerNameLabel.trailingAnchor.constraint(equalTo: trackerNameView.trailingAnchor),
            
        ])
    }
    
    private func setStreakView() {
        streakView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(streakView)
        
        streakView.addSubview(streakLabel)
        
        streakLabel.translatesAutoresizingMaskIntoConstraints = false
        
        streakView.addSubview(streakButton)
        
        streakButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            streakView.topAnchor.constraint(equalTo: trackerCardView.bottomAnchor),
            streakView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            streakView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            streakView.heightAnchor.constraint(equalToConstant: TrackerViewCollectionCustomCell.designedStreakViewHeight),
            
            streakButton.topAnchor.constraint(equalTo: streakView.topAnchor, constant: 8),
            streakButton.trailingAnchor.constraint(equalTo: streakView.trailingAnchor, constant: -12),
            
            streakButton.widthAnchor.constraint(equalToConstant: 34),
            streakButton.heightAnchor.constraint(equalToConstant: 34),
            
            streakLabel.leadingAnchor.constraint(equalTo: streakView.leadingAnchor, constant: 12),
            streakLabel.centerYAnchor.constraint(equalTo: streakButton.centerYAnchor)
            
        ])
    }
    
    private func getDayCountString(number: UInt16) -> String {
        switch number {
        case 1:
            return "день"
        case 2, 3, 4:
            return "дня"
        default:
            return "дней"
        }
    }
    
    @objc
    private func streakButtonWasPressed() {
        guard let color = streakButton.backgroundColor, let id else { return }
        
        if streakButton.isSelected {
            
            streakCount -= 1
            streakLabel.text = "\(streakCount) \(getDayCountString(number: streakCount))"
            
            UIView.animate(withDuration: 0.25) {
                self.streakButton.backgroundColor = color.withAlphaComponent(1)
            }
        } else {
            
            streakCount += 1
            streakLabel.text = "\(streakCount) \(getDayCountString(number: streakCount))"
            
            UIView.animate(withDuration: 0.25) {
                self.streakButton.backgroundColor = color.withAlphaComponent(0.3)
            }
        }

        streakButton.isSelected.toggle()
    
        delegate?.streakButtonWasPressed(buttonState: streakButton.isSelected, trackerId: id)
    }
}
