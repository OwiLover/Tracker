//
//  CustomCollection.swift
//  Tracker
//
//  Created by Owi Lover on 11/20/24.
//

import UIKit

final class TrackerCreatorCollectionHelper <T>: NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    private var elements: [T]
    private var spacing: CollectionSpacing
    private var headerTitle: String
    private var collectionView: UICollectionView
    
    private(set) var elementSize: CGFloat?
    
    private weak var delegate: TrackerCreatorCollectionHelperDelegate?
    
    init(headerTitle: String, elements: [T], spacing: CollectionSpacing, collection: UICollectionView, delegate: TrackerCreatorCollectionHelperDelegate? = nil) {
        self.elements = elements
        self.spacing = spacing
        self.headerTitle = headerTitle
        self.collectionView = collection
        self.delegate = delegate
        super.init()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(TrackerCreatorCollectionCell.self, forCellWithReuseIdentifier: TrackerCreatorCollectionCell.identifier)
        
        collectionView.register(CustomCollectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CustomCollectionHeader.identifier)
        
        collectionView.reloadData()
        
        print("Total Height: ",getTotalHeight())
        print("CustomCollectionHelper was created!")
    }
    
    deinit {
        print("CustomCollectionHelper was deleted!")
    }
    
    func getTotalHeight() -> CGFloat {
        guard let elementSize else { return 0 }
        let totalRows = CGFloat(Double(elements.count)/Double(spacing.elementsInRow)).rounded(.up)
        return elementSize * totalRows + spacing.topInset + spacing.bottomInset + spacing.spaceBetweenElementsInColumn * totalRows
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCreatorCollectionCell.identifier, for: indexPath) as? TrackerCreatorCollectionCell else {
            return UICollectionViewCell()
        }
        cell.prepareForReuse()
        
        if let cellText = elements[indexPath.row] as? String {
            cell.textLabel.text = cellText
        } else if let cellColor = elements[indexPath.row] as? UIColor {
            cell.contentView.backgroundColor = cellColor
        } else {
            return UICollectionViewCell()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let size = (collectionView.bounds.width - spacing.totalMarginInRow) / CGFloat(spacing.elementsInRow)
        
        elementSize = size
        
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: spacing.topInset, left: spacing.leftInset, bottom: spacing.bottomInset, right: spacing.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing.spaceBetweenElementsInRow
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing.spaceBetweenElementsInColumn
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CustomCollectionHeader.identifier, for: indexPath) as? CustomCollectionHeader else {
            return UICollectionReusableView()
        }
        header.prepareForReuse()
        header.setHeader(title: headerTitle)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)

        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.bounds.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                         withHorizontalFittingPriority: .required,
                                                         verticalFittingPriority: .fittingSizeLevel)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        guard let color = elements[indexPath.row] as? UIColor else {
    
            guard let text = elements[indexPath.row] as? String else { return }
            cell?.backgroundColor = .ypLightGray
            delegate?.cellWasPressed(content: text)
            return
        }
        cell?.layer.borderWidth = 3
        cell?.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        
        delegate?.cellWasPressed(content: color)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        
        cell?.backgroundColor = nil
        cell?.layer.borderWidth = 0
        cell?.layer.borderColor = nil
    }
}
