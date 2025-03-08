//
//  TrackerViewCollectionHelper.swift
//  Tracker
//
//  Created by Owi Lover on 12/1/24.
//

import UIKit

final class TrackerViewCollectionHelper: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private let collectionView: UICollectionView
    private var elements: [TrackerCategory]
    private var elementsRecord: TrackerRecordDictionary
    private var isCurrentDay: Bool
    
    private let spacing: CollectionSpacing = CollectionSpacing(elementsInRow: 2, leftInset: 16, rightInset: 16, topInset: 12, bottomInset: 16, spaceBetweenElementsInRow: 9, spaceBetweenElementsInColumn: 0)
    
    private weak var delegate: TrackerViewCollectionHelperDelegate?
    
    init(collectionView: UICollectionView, elements: [TrackerCategory]?, elementsRecordDictionary: TrackerRecordDictionary?, delegate: TrackerViewCollectionHelperDelegate? = nil, isCurrentDay: Bool = true) {
        self.collectionView = collectionView
        self.elements = elements ?? [TrackerCategory]()
        self.delegate = delegate
        self.isCurrentDay = isCurrentDay
        self.elementsRecord = elementsRecordDictionary ?? TrackerRecordDictionary()
        
        super.init()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        collectionView.register(TrackerViewCollectionCustomCell.self, forCellWithReuseIdentifier: TrackerViewCollectionCustomCell.identifier)
        collectionView.register(CustomCollectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CustomCollectionHeader.identifier)
        
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        elements[section].array.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerViewCollectionCustomCell.identifier, for: indexPath) as? TrackerViewCollectionCustomCell else {
            return UICollectionViewCell()
        }
        
        let element = elements[indexPath.section].array[indexPath.row]
        
        cell.prepareForReuse()
        
        let recordsDictionary = elementsRecord.dictionary[element.id]
        
        let streakCount: UInt16 = recordsDictionary?.streakCount ?? 0
        let isChecked = recordsDictionary?.isChecked ?? false
        
        cell.setupCell(id: element.id, emoji: element.emoji, name: element.name, backgroundColor: element.color, streakCount: streakCount, delegate: self, isEnabled: isCurrentDay, isSelected: isChecked)
        
        return cell
    }
    
    func reloadCollection(newElements: [TrackerCategory], isCurrentDay: Bool) {
        elements = newElements
        self.isCurrentDay = isCurrentDay
        self.collectionView.reloadData()
    }
    
    func updateElementRecords(elementRecordDictionary: TrackerRecordDictionary) {
        self.elementsRecord = elementRecordDictionary
    }
}

extension TrackerViewCollectionHelper: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - spacing.totalMarginInRow)/CGFloat(spacing.elementsInRow)
        let height = TrackerViewCollectionCustomCell.designedHeight
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: spacing.topInset, left: spacing.leftInset, bottom: spacing.bottomInset, right: spacing.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing.spaceBetweenElementsInColumn
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing.spaceBetweenElementsInRow
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CustomCollectionHeader.identifier, for: indexPath) as? CustomCollectionHeader else {
                return UICollectionReusableView()
            }
            header.prepareForReuse()
            let headerTitle = elements[indexPath.section].category
            header.setHeader(title: headerTitle)
            return header
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: CustomCollectionHeader.getRequiredSize)
    }
}

extension TrackerViewCollectionHelper: TrackerViewCollectionCustomCellDelegate {
    func streakButtonWasPressed(buttonState: Bool, trackerId: UUID) {
        delegate?.updateStreak(shouldIncrease: buttonState, trackerId: trackerId)
    }
}
