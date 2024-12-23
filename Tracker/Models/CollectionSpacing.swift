//
//  CollectionSpacing.swift
//  Tracker
//
//  Created by Owi Lover on 11/20/24.
//

import Foundation

struct CollectionSpacing {
    let elementsInRow: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let topInset: CGFloat
    let bottomInset: CGFloat
    let spaceBetweenElementsInRow: CGFloat
    let spaceBetweenElementsInColumn: CGFloat
    let totalMarginInRow: CGFloat
    
    init(elementsInRow: Int, leftInset: CGFloat, rightInset: CGFloat, topInset: CGFloat, bottomInset: CGFloat, spaceBetweenElementsInRow: CGFloat, spaceBetweenElementsInColumn: CGFloat) {
        self.elementsInRow = elementsInRow
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.topInset = topInset
        self.bottomInset = bottomInset
        self.spaceBetweenElementsInRow = spaceBetweenElementsInRow
        self.spaceBetweenElementsInColumn = spaceBetweenElementsInColumn
        self.totalMarginInRow = leftInset + rightInset + CGFloat(elementsInRow - 1) * spaceBetweenElementsInRow
    }
}
